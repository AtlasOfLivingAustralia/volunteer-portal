CREATE INDEX vp_user_volunteer_score_idx ON vp_user((transcribed_count + validated_count));
CREATE INDEX vp_user_validated_count_transcribed_count_idx ON vp_user(transcribed_count, validated_count);
