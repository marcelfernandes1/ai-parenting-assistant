-- CreateTable
CREATE TABLE "MilestoneContent" (
    "id" TEXT NOT NULL,
    "milestoneType" "MilestoneType" NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "whatToExpect" TEXT NOT NULL,
    "howToEncourage" TEXT NOT NULL,
    "redFlags" TEXT NOT NULL,
    "expertTips" TEXT[],
    "relatedMilestones" TEXT[],
    "videoUrl" TEXT,
    "imageUrl" TEXT,
    "ageRangeMonths" JSONB NOT NULL,
    "sources" TEXT[],
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "MilestoneContent_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "MilestoneContent_name_key" ON "MilestoneContent"("name");

-- CreateIndex
CREATE INDEX "MilestoneContent_name_idx" ON "MilestoneContent"("name");

-- CreateIndex
CREATE INDEX "MilestoneContent_milestoneType_idx" ON "MilestoneContent"("milestoneType");
