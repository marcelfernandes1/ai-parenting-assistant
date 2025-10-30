/**
 * OpenAI Service
 *
 * Handles all interactions with OpenAI API including:
 * - Chat completions (GPT-4)
 * - Audio transcription (Whisper)
 * - Text-to-speech (TTS)
 */

import OpenAI from 'openai';

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
                url: imageUrl,
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
