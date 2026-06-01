/*
  ==================================================
  RunX Realtime Social Schema Additions
  ==================================================
  Objective: Realtime feeds, follows, and live interactions.
  Execute this in the Supabase SQL Editor.
*/

-- 1. FOLLOWS SYSTEM
CREATE TABLE public.follows (
  follower_id UUID REFERENCES public.profiles(id) NOT NULL,
  following_id UUID REFERENCES public.profiles(id) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (follower_id, following_id)
);

ALTER TABLE public.follows ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own follows" ON public.follows FOR SELECT USING (auth.uid() = follower_id OR auth.uid() = following_id);
CREATE POLICY "Users can follow others" ON public.follows FOR INSERT WITH CHECK (auth.uid() = follower_id);
CREATE POLICY "Users can unfollow" ON public.follows FOR DELETE USING (auth.uid() = follower_id);

-- 2. ACTIVITY FEED
CREATE TABLE public.activity_feed (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) NOT NULL,
  type TEXT NOT NULL, -- 'run', 'achievement', 'challenge', 'milestone'
  data JSONB NOT NULL, -- Details like { distance: 5.2, title: 'Morning Run' }
  timestamp TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.activity_feed ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view activity feed" ON public.activity_feed FOR SELECT USING (TRUE);
CREATE POLICY "Users can post own activity" ON public.activity_feed FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 3. SOCIAL INTERACTIONS (LIKES)
CREATE TABLE public.feed_likes (
  feed_item_id UUID REFERENCES public.activity_feed(id) ON DELETE CASCADE,
  user_id UUID REFERENCES public.profiles(id) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (feed_item_id, user_id)
);

ALTER TABLE public.feed_likes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view likes" ON public.feed_likes FOR SELECT USING (TRUE);
CREATE POLICY "Users can like items" ON public.feed_likes FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can unlike" ON public.feed_likes FOR DELETE USING (auth.uid() = user_id);

-- 4. ENABLE REALTIME
-- Note: Profiles is already added in some setups, ensuring it's in the publication for live rankings.
ALTER PUBLICATION supabase_realtime ADD TABLE public.activity_feed;
ALTER PUBLICATION supabase_realtime ADD TABLE public.feed_likes;
ALTER PUBLICATION supabase_realtime ADD TABLE public.profiles;
