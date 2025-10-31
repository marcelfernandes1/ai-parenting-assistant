/**
 * OpenAI Service
 *
 * Handles all interactions with OpenAI API including:
 * - Chat completions (GPT-4)
 * - Audio transcription (Whisper)
 * - Text-to-speech (TTS)
 */

import OpenAI from 'openai';
import { promises as fs } from 'fs';
import path from 'path';

// Initialize OpenAI client with API key from environment variable
// Throws error if OPENAI_API_KEY is not set in .env file
if (!process.env.OPENAI_API_KEY) {
  throw new Error('OPENAI_API_KEY is not set in environment variables');
}

/// OpenAI client instance used throughout the application
/// Configured with API key from environment variables
export const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

/**
 * Message interface for chat context
 * Matches OpenAI's ChatCompletionMessageParam format
 */
export interface ChatMessage {
  role: 'system' | 'user' | 'assistant';
  content: string;
}

/**
 * User profile data for building personalized system prompts
 */
export interface UserProfile {
  mode?: 'PREGNANCY' | 'PARENTING';
  babyName?: string | null;
  babyBirthDate?: Date | null;
  dueDate?: Date | null;
  parentingPhilosophy?: string;
  religiousViews?: string;
  culturalBackground?: string | null;
  concerns?: string[];
}

/**
 * Builds a personalized system prompt based on user profile data.
 * This prompt guides the AI's behavior and responses.
 *
 * @param profile - User profile data from database
 * @returns System prompt string for OpenAI
 */
export function buildSystemPrompt(profile: UserProfile): string {
  const { mode, babyName, babyBirthDate, dueDate, parentingPhilosophy, religiousViews, culturalBackground, concerns } = profile;

  // Calculate baby age or weeks pregnant
  let ageContext = '';
  if (mode === 'PREGNANCY' && dueDate) {
    const today = new Date();
    const weeksPregnant = Math.floor((dueDate.getTime() - today.getTime()) / (1000 * 60 * 60 * 24 * 7));
    const weeksElapsed = 40 - weeksPregnant;
    ageContext = `The user is currently ${weeksElapsed} weeks pregnant, with a due date on ${dueDate.toLocaleDateString()}.`;
  } else if (mode === 'PARENTING' && babyBirthDate) {
    const today = new Date();
    const ageInDays = Math.floor((today.getTime() - babyBirthDate.getTime()) / (1000 * 60 * 60 * 24));
    const ageInMonths = Math.floor(ageInDays / 30);
    const ageInWeeks = Math.floor(ageInDays / 7);

    if (ageInMonths < 3) {
      ageContext = `The user has a ${ageInWeeks}-week-old baby${babyName ? ` named ${babyName}` : ''}.`;
    } else {
      ageContext = `The user has a ${ageInMonths}-month-old baby${babyName ? ` named ${babyName}` : ''}.`;
    }
  }

  // Build concerns section
  let concernsContext = '';
  if (concerns && concerns.length > 0) {
    concernsContext = `\nThe user's primary concerns are: ${concerns.join(', ')}.`;
  }

  // Build parenting philosophy context
  let philosophyContext = '';
  if (parentingPhilosophy) {
    try {
      const philosophy = typeof parentingPhilosophy === 'string' ? JSON.parse(parentingPhilosophy) : parentingPhilosophy;
      philosophyContext = `\nParenting approach: ${philosophy}.`;
    } catch (e) {
      // If parsing fails, use as string
      philosophyContext = `\nParenting approach: ${parentingPhilosophy}.`;
    }
  }

  // Build religious/cultural context
  let culturalContext = '';
  if (religiousViews || culturalBackground) {
    const parts = [];
    if (religiousViews) {
      try {
        const views = typeof religiousViews === 'string' ? JSON.parse(religiousViews) : religiousViews;
        parts.push(`Religious views: ${views}`);
      } catch (e) {
        parts.push(`Religious views: ${religiousViews}`);
      }
    }
    if (culturalBackground) {
      parts.push(`Cultural background: ${culturalBackground}`);
    }
    culturalContext = `\n` + parts.join('. ');
  }

  // Construct full system prompt
  const systemPrompt = `You are a warm, empathetic, and knowledgeable parenting assistant. Your role is to provide supportive guidance to parents and expecting parents.

${ageContext}${concernsContext}${philosophyContext}${culturalContext}

**Guidelines:**
- Be warm, empathetic, and reassuring in your tone
- Provide evidence-based information when possible
- Acknowledge that every baby and family is different
- Use the baby's name (${babyName || 'the baby'}) naturally in responses
- Respect the user's parenting philosophy and cultural background
- If discussing religious or cultural topics, be sensitive and inclusive

**Important Safety Rules:**
- NEVER provide definitive medical diagnoses
- For urgent medical situations (high fever, difficulty breathing, severe injuries), IMMEDIATELY advise seeking emergency medical care
- For concerning symptoms, recommend contacting a pediatrician
- Clearly distinguish between general information and medical advice
- Include disclaimers when appropriate: "I'm not a doctor, but..."

**Conversation Style:**
- Ask clarifying questions when needed
- Provide practical, actionable advice
- Share relevant age-appropriate information
- Be encouraging and supportive
- Avoid overwhelming the user with too much information at once

Remember: Your goal is to support and empower parents, not replace professional medical care.`;

  return systemPrompt;
}

/**
 * Generates a chat response using OpenAI GPT-4.
 *
 * Takes conversation history and user profile to generate context-aware responses.
 * Includes system prompt personalized to user's situation.
 *
 * @param messages - Array of conversation messages (user and assistant messages)
 * @param profile - User profile data for personalization
 * @returns Object containing assistant response and token count
 */
export async function generateChatResponse(
  messages: ChatMessage[],
  profile: UserProfile
): Promise<{ response: string; tokensUsed: number }> {
  try {
    // Build system prompt from user profile
    const systemPrompt = buildSystemPrompt(profile);

    // Prepare messages array with system prompt first
    const messagesWithSystem: ChatMessage[] = [
      { role: 'system', content: systemPrompt },
      ...messages, // Last 10 messages from conversation history
    ];

    // Call OpenAI Chat Completions API
    // Using GPT-4 Turbo for best quality responses
    const completion = await openai.chat.completions.create({
      model: 'gpt-4-turbo-preview', // GPT-4 Turbo for speed and cost efficiency
      messages: messagesWithSystem,
      temperature: 0.7, // Balanced between creativity and consistency
      max_tokens: 800, // Limit response length to keep conversations concise
      top_p: 0.9, // Nucleus sampling for more focused responses
    });

    // Extract response text and token usage
    const assistantMessage = completion.choices[0]?.message?.content || '';
    const tokensUsed = completion.usage?.total_tokens || 0;

    return {
      response: assistantMessage,
      tokensUsed,
    };
  } catch (error) {
    // Log error for debugging
    console.error('OpenAI API error:', error);

    // Throw user-friendly error
    if (error instanceof Error) {
      throw new Error(`Failed to generate AI response: ${error.message}`);
    }
    throw new Error('Failed to generate AI response');
  }
}

/**
 * Transcribes audio file to text using OpenAI Whisper API.
 *
 * Accepts audio file path and returns transcribed text.
 * Supports formats: mp3, mp4, m4a, wav, webm
 *
 * @param audioFilePath - Path to audio file on disk
 * @returns Transcribed text
 */
export async function transcribeAudio(audioFilePath: string): Promise<string> {
  try {
    // Import fs to create readable stream for Whisper API
    const fs = await import('fs');

    // Call OpenAI Whisper API for transcription
    // whisper-1 is the only model available for transcription
    const transcription = await openai.audio.transcriptions.create({
      file: fs.createReadStream(audioFilePath),
      model: 'whisper-1',
      language: 'en', // English language for better accuracy
      response_format: 'text', // Return plain text instead of JSON
    });

    // Whisper returns string directly when response_format is 'text'
    return (transcription as unknown as string).trim();
  } catch (error) {
    // Log error for debugging
    console.error('Whisper API error:', error);

    // Throw user-friendly error
    if (error instanceof Error) {
      throw new Error(`Failed to transcribe audio: ${error.message}`);
    }
    throw new Error('Failed to transcribe audio');
  }
}

/**
 * Generates a concise, descriptive title for a conversation based on its content.
 * Uses GPT-4 to analyze the conversation and create a meaningful title (like ChatGPT does).
 *
 * @param messages - Array of conversation messages (first 3-4 messages work best)
 * @returns Conversation title string (e.g., "Sleep training tips for 4-month-old")
 */
export async function generateConversationTitle(messages: ChatMessage[]): Promise<string> {
  try {
    // Build prompt for title generation
    const titlePrompt = `Based on the following conversation, generate a short, descriptive title (max 6 words).
The title should capture the main topic or question being discussed.
Use simple, clear language that a parent would understand.

Examples of good titles:
- "Sleep training for 4-month-old"
- "Introducing solid foods advice"
- "Diaper rash treatment options"
- "First smile milestone questions"
- "Breastfeeding latch problems"

Conversation:
${messages.map(m => `${m.role.toUpperCase()}: ${m.content}`).join('\n')}

Generate ONLY the title, nothing else:`;

    // Call OpenAI with a smaller, faster model for title generation
    const completion = await openai.chat.completions.create({
      model: 'gpt-4o-mini', // Faster and cheaper model for simple tasks
      messages: [{ role: 'user', content: titlePrompt }],
      temperature: 0.5, // Lower temperature for consistent, focused titles
      max_tokens: 20, // Short titles only
    });

    // Extract and clean the title
    let title = completion.choices[0]?.message?.content?.trim() || 'New Conversation';

    // Remove quotes if AI added them
    title = title.replace(/^["']|["']$/g, '');

    // Limit title length
    if (title.length > 50) {
      title = title.substring(0, 47) + '...';
    }

    return title;
  } catch (error) {
    console.error('Failed to generate conversation title:', error);
    // Return default title on error
    return 'New Conversation';
  }
}

/**
 * Generates a summary of the conversation for semantic search.
 * Creates a comprehensive summary that captures key topics and questions.
 *
 * @param messages - Array of all conversation messages
 * @returns Conversation summary string for search indexing
 */
export async function generateConversationSummary(messages: ChatMessage[]): Promise<string> {
  try {
    // Build prompt for summary generation
    const summaryPrompt = `Summarize the following conversation in 2-3 sentences.
Focus on the main topics, questions, and key advice given.
Use keywords that would help someone search for this conversation later.

Conversation:
${messages.map(m => `${m.role.toUpperCase()}: ${m.content}`).join('\n')}

Summary:`;

    // Call OpenAI for summary generation
    const completion = await openai.chat.completions.create({
      model: 'gpt-4o-mini', // Fast model for summarization
      messages: [{ role: 'user', content: summaryPrompt }],
      temperature: 0.3, // Very focused, factual summaries
      max_tokens: 150, // Concise summaries
    });

    const summary = completion.choices[0]?.message?.content?.trim() || '';
    return summary;
  } catch (error) {
    console.error('Failed to generate conversation summary:', error);
    // Return empty string on error
    return '';
  }
}

/**
 * Performs AI-powered semantic search through conversation summaries.
 * Uses GPT to understand the search intent and find relevant conversations.
 *
 * @param searchQuery - User's search query (e.g., "sleep problems", "feeding advice")
 * @param conversations - Array of conversations with their summaries
 * @returns Array of relevant conversation IDs ranked by relevance
 */
export async function searchConversations(
  searchQuery: string,
  conversations: Array<{ sessionId: string; title: string; summary: string }>
): Promise<string[]> {
  try {
    // Build search prompt that asks AI to rank conversations by relevance
    const conversationList = conversations.map((conv, index) => {
      return `${index + 1}. [${conv.sessionId}] ${conv.title}\n   Summary: ${conv.summary}`;
    }).join('\n\n');

    const searchPrompt = `You are helping a parent search through their past conversations about parenting and baby care.

Search query: "${searchQuery}"

Available conversations:
${conversationList}

Based on the search query, rank the conversations from most to least relevant.
Return ONLY the session IDs in order of relevance, separated by commas.
Include only conversations that are actually relevant to the search query.
If no conversations match well, return an empty list.

Example response: session-id-1, session-id-2, session-id-3

Ranked session IDs:`;

    // Call OpenAI for semantic search
    const completion = await openai.chat.completions.create({
      model: 'gpt-4o-mini', // Fast model for search ranking
      messages: [{ role: 'user', content: searchPrompt }],
      temperature: 0.2, // Very consistent, focused results
      max_tokens: 200,
    });

    const result = completion.choices[0]?.message?.content?.trim() || '';

    // Parse the comma-separated session IDs
    const sessionIds = result
      .split(',')
      .map(id => id.trim())
      .filter(id => id.length > 0);

    return sessionIds;
  } catch (error) {
    console.error('Failed to perform AI search:', error);
    // Return empty array on error (no results)
    return [];
  }
}

/**
 * Generates searchable categories and tags for a baby photo using OpenAI Vision API.
 *
 * Categories help organize photos and make them searchable by:
 * - Activities: smiling, crying, sleeping, eating, playing, bath time, tummy time
 * - Location: indoor, outdoor, park, home, car
 * - People: alone, with parent, with siblings, with family
 * - Objects: toys, bottle, pacifier, blanket, stroller
 * - Milestones: first steps, first smile, crawling, sitting up
 * - Mood: happy, content, fussy, peaceful, excited
 *
 * @param imageUrl - URL or base64-encoded image to categorize
 * @param userContext - Optional context about the baby (age, name)
 * @returns Object containing categories array, description, and detected objects
 */
export async function categorizePhoto(
  imageUrl: string,
  userContext?: { babyAge?: string; babyName?: string }
): Promise<{
  categories: string[];
  description: string;
  objects: string[];
  mood?: string;
  activity?: string;
  location?: string;
}> {
  try {
    // Build prompt for photo categorization
    const categorizationPrompt = `You are analyzing a baby photo to generate searchable categories and tags.

${userContext?.babyAge ? `Baby's age: ${userContext.babyAge}` : ''}
${userContext?.babyName ? `Baby's name: ${userContext.babyName}` : ''}

Analyze this photo and provide a JSON response with the following structure:
{
  "description": "A brief 1-sentence description of the photo",
  "mood": "The baby's mood (happy, content, fussy, peaceful, excited, curious, sleepy, crying, neutral)",
  "activity": "Main activity (sleeping, eating, playing, bath time, tummy time, crawling, walking, sitting, feeding, diaper change, outdoor play, car ride)",
  "location": "Location setting (home, bedroom, living room, kitchen, nursery, outdoor, park, car, beach, playground, restaurant, doctor office)",
  "objects": ["List of visible objects relevant to baby care: toys, bottle, pacifier, blanket, stroller, high chair, crib, books, stuffed animals, etc."],
  "categories": ["All relevant categories from mood, activity, location, and key descriptors"]
}

Guidelines:
- Be specific but concise
- Include 5-10 relevant categories
- Focus on searchable terms parents would use
- Include developmental milestones if visible (first steps, first smile, sitting up, crawling)
- Identify all baby-related objects in the scene
- Use lowercase for all categories
- Categories should be single words or short phrases

Respond ONLY with valid JSON, no additional text.`;

    // Call OpenAI Vision API with JSON response format
    const response = await openai.chat.completions.create({
      model: 'gpt-4o', // GPT-4o with vision capabilities
      messages: [
        {
          role: 'user',
          content: [
            {
              type: 'text',
              text: categorizationPrompt,
            },
            {
              type: 'image_url',
              image_url: {
                url: imageUrl,
                detail: 'low', // Low detail is sufficient for categorization
              },
            },
          ],
        },
      ],
      response_format: { type: 'json_object' }, // Request JSON response
      max_tokens: 500,
      temperature: 0.3, // Low temperature for consistent categorization
    });

    // Parse the JSON response
    const result = JSON.parse(response.choices[0]?.message?.content || '{}');

    return {
      categories: result.categories || [],
      description: result.description || '',
      objects: result.objects || [],
      mood: result.mood,
      activity: result.activity,
      location: result.location,
    };
  } catch (error) {
    console.error('OpenAI Vision categorization error:', error);

    // Return default empty response on error
    return {
      categories: [],
      description: '',
      objects: [],
    };
  }
}

/**
 * Analyzes a baby photo using OpenAI Vision API (GPT-4o).
 *
 * Provides visual analysis for baby-related concerns such as:
 * - Skin rashes or discoloration
 * - Diaper contents analysis
 * - Safety hazards in environment
 * - General visual concerns
 *
 * @param imageUrl - URL or base64-encoded image to analyze
 * @param userContext - Optional context about the baby (age, specific concerns)
 * @returns Object containing analysis text and medical disclaimer
 */
export async function analyzePhoto(
  imageUrl: string,
  userContext?: { babyAge?: string; concerns?: string }
): Promise<{ analysis: string; disclaimer: string }> {
  try {
    // Build specific prompt for baby photo analysis
    const analysisPrompt = `You are a knowledgeable parenting assistant analyzing a baby-related photo.

${userContext?.babyAge ? `Baby's age: ${userContext.babyAge}` : ''}
${userContext?.concerns ? `Parent's specific concern: ${userContext.concerns}` : ''}

Please analyze this photo and provide helpful observations about:

1. **Skin condition**: Any visible rashes, discoloration, birthmarks, or skin concerns
2. **Diaper contents** (if applicable): Color, consistency, and whether it appears normal
3. **Safety hazards**: Any potential dangers in the baby's environment (sharp objects, choking hazards, unsafe sleep positions)
4. **General observations**: Overall appearance, clothing appropriateness, developmental signs

**Important guidelines:**
- Be descriptive but not alarmist
- Use clear, parent-friendly language
- Distinguish between what appears normal vs. what may warrant attention
- NEVER provide definitive medical diagnoses
- For concerning findings, recommend consulting a pediatrician
- Be culturally sensitive and non-judgmental

Focus on being helpful and informative while maintaining appropriate medical boundaries.`;

    // Handle local file URLs by converting to base64
    let imageUrlOrBase64 = imageUrl;

    // Check if this is a localhost URL
    if (imageUrl.includes('localhost') || imageUrl.includes('127.0.0.1')) {
      console.log('📸 Detected local file URL, converting to base64...');

      try {
        // Extract the file path from the URL (e.g., /uploads/userId/filename.jpg)
        const urlPath = new URL(imageUrl).pathname;

        // Construct the full file path (uploads directory is relative to backend root)
        const filePath = path.join(process.cwd(), urlPath.substring(1)); // Remove leading '/'

        console.log(`📂 Reading file from: ${filePath}`);

        // Read the file as a buffer
        const fileBuffer = await fs.readFile(filePath);

        // Convert to base64
        const base64Image = fileBuffer.toString('base64');

        // Determine MIME type from file extension
        const ext = path.extname(filePath).toLowerCase();
        const mimeType = ext === '.png' ? 'image/png' : 'image/jpeg';

        // Create data URL
        imageUrlOrBase64 = `data:${mimeType};base64,${base64Image}`;

        console.log(`✅ Converted local file to base64 (${fileBuffer.length} bytes)`);
      } catch (fileError) {
        console.error('Error reading local file:', fileError);
        throw new Error('Failed to read local image file for analysis');
      }
    }

    // Call OpenAI Vision API (GPT-4o with vision capabilities)
    const response = await openai.chat.completions.create({
      model: 'gpt-4o', // GPT-4o has vision capabilities
      messages: [
        {
          role: 'user',
          content: [
            {
              type: 'text',
              text: analysisPrompt,
            },
            {
              type: 'image_url',
              image_url: {
                url: imageUrlOrBase64,
                detail: 'high', // High detail for better medical/safety analysis
              },
            },
          ],
        },
      ],
      max_tokens: 1000, // Allow detailed analysis
      temperature: 0.5, // Lower temperature for more consistent, factual analysis
    });

    // Extract analysis text from response
    const analysis = response.choices[0]?.message?.content || '';

    // Standard medical disclaimer for all photo analyses
    const disclaimer = `⚠️ **Medical Disclaimer**: This analysis is for informational purposes only and is not a substitute for professional medical advice, diagnosis, or treatment. If you have concerns about your baby's health, please consult a qualified pediatrician or healthcare provider.`;

    return {
      analysis,
      disclaimer,
    };
  } catch (error) {
    // Log error for debugging
    console.error('OpenAI Vision API error:', error);

    // Throw user-friendly error
    if (error instanceof Error) {
      throw new Error(`Failed to analyze photo: ${error.message}`);
    }
    throw new Error('Failed to analyze photo');
  }
}
