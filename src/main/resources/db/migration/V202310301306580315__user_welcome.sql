/*
    Add welcome email flag to vp_user table
    By: Chris Dunstall
*/

ALTER TABLE "vp_user"
    ADD "welcome_date" TIMESTAMP NULL;
COMMENT ON COLUMN "vp_user"."welcome_date" IS '';

-- Set field to true for all pre-existing users.
UPDATE vp_user SET welcome_date = '2023-10-01 00:00:00' WHERE welcome_date IS NULL;