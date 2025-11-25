-- Supabase Schema for Brain Tests App
-- Generated on November 22, 2025
-- Designed to sync with Drift (SQLite) schema version 11

-- -----------------------------------------------------------------------------
-- 1. Setup & Extensions
-- -----------------------------------------------------------------------------

-- Enable UUID extension for generating UUIDs
create extension if not exists "uuid-ossp";

-- -----------------------------------------------------------------------------
-- 2. Tables
-- -----------------------------------------------------------------------------

-- Table: user_profiles
-- Syncs with: UserProfileTable
create table public.user_profiles (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references auth.users(id) on delete cascade,
  
  -- Core Data
  name text,
  age integer,
  date_of_birth timestamp with time zone,
  gender text,
  program_start_date timestamp with time zone,
  
  -- Metadata
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null,
  
  -- Constraints
  unique(user_id) -- One profile per user
);

-- Table: assessments
-- Syncs with: AssessmentTable
create table public.assessments (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references auth.users(id) on delete cascade,
  
  -- Core Data
  type text not null, -- Enum: AssessmentType
  score integer not null,
  max_score integer not null,
  notes text,
  completed_at timestamp with time zone not null,
  
  -- Metadata
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Table: cognitive_exercises
-- Syncs with: CognitiveExerciseTable
create table public.cognitive_exercises (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references auth.users(id) on delete cascade,
  
  -- Core Data
  name text not null,
  type text not null, -- Enum: ExerciseType
  difficulty text not null, -- Enum: ExerciseDifficulty
  score integer,
  max_score integer not null,
  time_spent_seconds integer,
  is_completed boolean default false not null,
  exercise_data text, -- JSON data
  completed_at timestamp with time zone,
  
  -- Metadata
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Table: cambridge_assessments
-- Syncs with: CambridgeAssessmentTable
create table public.cambridge_assessments (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references auth.users(id) on delete cascade,
  
  -- Core Data
  test_type text not null, -- Enum: CambridgeTestType
  duration_seconds integer not null,
  accuracy double precision not null,
  total_trials integer not null,
  correct_trials integer not null,
  error_count integer not null,
  mean_latency_ms double precision not null,
  median_latency_ms double precision not null,
  norm_score double precision not null,
  interpretation text not null,
  specific_metrics text not null, -- JSON data
  completed_at timestamp with time zone not null,
  
  -- Metadata
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Table: daily_goals
-- Syncs with: DailyGoalsTable
create table public.daily_goals (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references auth.users(id) on delete cascade,
  
  -- Core Data
  date timestamp with time zone not null,
  target_games integer default 5 not null,
  completed_games integer default 0 not null,
  is_completed boolean default false not null,
  
  -- Metadata
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);


-- -----------------------------------------------------------------------------
-- 3. Row Level Security (RLS)
-- -----------------------------------------------------------------------------

-- Enable RLS on all tables
alter table public.user_profiles enable row level security;
alter table public.assessments enable row level security;
alter table public.cognitive_exercises enable row level security;
alter table public.cambridge_assessments enable row level security;
alter table public.daily_goals enable row level security;

-- Create Policies
-- Users can only see and edit their own data

-- user_profiles
create policy "Users can view their own profile" on public.user_profiles
  for select using (auth.uid() = user_id);

create policy "Users can insert their own profile" on public.user_profiles
  for insert with check (auth.uid() = user_id);

create policy "Users can update their own profile" on public.user_profiles
  for update using (auth.uid() = user_id);

-- assessments
create policy "Users can view their own assessments" on public.assessments
  for select using (auth.uid() = user_id);

create policy "Users can insert their own assessments" on public.assessments
  for insert with check (auth.uid() = user_id);

create policy "Users can update their own assessments" on public.assessments
  for update using (auth.uid() = user_id);

-- cognitive_exercises
create policy "Users can view their own exercises" on public.cognitive_exercises
  for select using (auth.uid() = user_id);

create policy "Users can insert their own exercises" on public.cognitive_exercises
  for insert with check (auth.uid() = user_id);

create policy "Users can update their own exercises" on public.cognitive_exercises
  for update using (auth.uid() = user_id);

-- cambridge_assessments
create policy "Users can view their own cambridge assessments" on public.cambridge_assessments
  for select using (auth.uid() = user_id);

create policy "Users can insert their own cambridge assessments" on public.cambridge_assessments
  for insert with check (auth.uid() = user_id);

create policy "Users can update their own cambridge assessments" on public.cambridge_assessments
  for update using (auth.uid() = user_id);

-- daily_goals
create policy "Users can view their own daily goals" on public.daily_goals
  for select using (auth.uid() = user_id);

create policy "Users can insert their own daily goals" on public.daily_goals
  for insert with check (auth.uid() = user_id);

create policy "Users can update their own daily goals" on public.daily_goals
  for update using (auth.uid() = user_id);


-- -----------------------------------------------------------------------------
-- 4. Realtime (Optional)
-- -----------------------------------------------------------------------------

-- Enable realtime for these tables if you want clients to subscribe to changes
alter publication supabase_realtime add table public.user_profiles;
alter publication supabase_realtime add table public.assessments;
alter publication supabase_realtime add table public.cognitive_exercises;
alter publication supabase_realtime add table public.cambridge_assessments;
alter publication supabase_realtime add table public.daily_goals;
