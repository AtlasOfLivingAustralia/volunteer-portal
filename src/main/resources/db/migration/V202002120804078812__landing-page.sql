CREATE TABLE IF NOT EXISTS landing_page (
  id bigint NOT NULL PRIMARY KEY,
  title text NOT NULL,
  body_copy text,
  enabled boolean DEFAULT FALSE NOT NULL,
  number_of_contributors integer DEFAULT 10 NOT NULL,
  landing_page_image text,
  image_attribution text,
  project_type_id bigint,
  version bigint NOT NULL,
  date_created timestamp without time zone NOT NULL,
  last_updated timestamp without time zone NOT NULL
);


CREATE TABLE IF NOT EXISTS landing_page_label (
   landing_page_id bigint NOT NULL,
   label_id bigint NOT NULL,
   PRIMARY KEY (landing_page_id, label_id),
   FOREIGN KEY (landing_page_id) REFERENCES landing_page (id),
   FOREIGN KEY (label_id) REFERENCES label (id)
)