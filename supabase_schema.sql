/*
  ==================================================
  RunX Production Database Schema
  ==================================================
  Objective: Scalable, User-Isolated, and Secure.
  Execute this in the Supabase SQL Editor.
*/

-- 1. USER PROFILES
CREATE TABLE public.profiles (
  id UUID REFERENCES auth.users NOT NULL PRIMARY KEY,
  full_name TEXT,
  avatar_url TEXT,
  age INTEGER,
  weight DOUBLE PRECISION,
  height INTEGER,
  goal TEXT,
  level INTEGER DEFAULT 1,
  xp INTEGER DEFAULT 0,
  total_distance DOUBLE PRECISION DEFAULT 0.0,
  total_calories DOUBLE PRECISION DEFAULT 0.0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile" ON public.profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- 2. RUN SESSIONS
CREATE TABLE public.runs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users NOT NULL,
  distance DOUBLE PRECISION NOT NULL,
  calories DOUBLE PRECISION NOT NULL,
  duration INTEGER NOT NULL,
  average_pace DOUBLE PRECISION,
  route_points JSONB,
  date TEXT NOT NULL,
  timestamp TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.runs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own runs" ON public.runs FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own runs" ON public.runs FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE INDEX idx_runs_user_id ON public.runs(user_id);

-- 3. XP & STREAKS
CREATE TABLE public.xp_progress (
  user_id UUID REFERENCES auth.users NOT NULL PRIMARY KEY,
  total_xp INTEGER DEFAULT 0,
  current_streak INTEGER DEFAULT 0,
  longest_streak INTEGER DEFAULT 0,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.xp_progress ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own xp" ON public.xp_progress FOR ALL USING (auth.uid() = user_id);

-- 4. ACHIEVEMENTS
CREATE TABLE public.achievements (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users NOT NULL,
  achievement_title TEXT NOT NULL,
  unlocked_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, achievement_title)
);

ALTER TABLE public.achievements ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own achievements" ON public.achievements FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own achievements" ON public.achievements FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 5. CHALLENGES
CREATE TABLE public.challenges_progress (
  user_id UUID REFERENCES auth.users NOT NULL,
  challenge_id TEXT NOT NULL,
  progress DOUBLE PRECISION DEFAULT 0.0,
  is_completed BOOLEAN DEFAULT FALSE,
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (user_id, challenge_id)
);

ALTER TABLE public.challenges_progress ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own challenge progress" ON public.challenges_progress FOR ALL USING (auth.uid() = user_id);

-- 6. COMMUNITIES
CREATE TABLE public.communities (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  members_count INTEGER DEFAULT 0,
  category TEXT,
  image TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.communities ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view communities" ON public.communities FOR SELECT USING (TRUE);

CREATE TABLE public.community_members (
  community_id UUID REFERENCES public.communities NOT NULL,
  user_id UUID REFERENCES auth.users NOT NULL,
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (community_id, user_id)
);

ALTER TABLE public.community_members ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own memberships" ON public.community_members FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can join communities" ON public.community_members FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 7. USER SETTINGS
CREATE TABLE public.user_settings (
  user_id UUID REFERENCES auth.users NOT NULL PRIMARY KEY,
  is_metric BOOLEAN DEFAULT TRUE,
  auto_follow_map BOOLEAN DEFAULT TRUE,
  notifications_enabled BOOLEAN DEFAULT TRUE,
  is_dark_mode BOOLEAN DEFAULT TRUE,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.user_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own settings" ON public.user_settings FOR ALL USING (auth.uid() = user_id);
