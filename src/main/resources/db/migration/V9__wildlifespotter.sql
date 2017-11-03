CREATE TABLE IF NOT EXISTS wildlife_spotter (
  id bigint NOT NULL PRIMARY KEY,
  body_copy text,
  number_of_contributors integer DEFAULT 10 NOT NULL,
  hero_image text,
  hero_image_attribution text,
  version bigint NOT NULL,
  date_created timestamp without time zone NOT NULL,
  last_updated timestamp without time zone NOT NULL
);

ALTER TABLE template ADD COLUMN IF NOT EXISTS view_params2 jsonb;