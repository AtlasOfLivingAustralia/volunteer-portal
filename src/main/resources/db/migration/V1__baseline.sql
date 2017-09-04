--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.5
-- Dumped by pg_dump version 9.6.5

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;
--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';
--
-- Name: fuzzystrmatch; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;
--
-- Name: EXTENSION fuzzystrmatch; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';
SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: achievement; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE achievement (
    id bigint NOT NULL,
    version bigint NOT NULL,
    date_achieved timestamp without time zone,
    name character varying(255) NOT NULL,
    user_id bigint NOT NULL
);

--
-- Name: achievement_award; Type: TABLE; Schema: public; Owner: volunteers
--

CREATE TABLE achievement_award (
    id bigint NOT NULL,
    version bigint NOT NULL,
    achievement_id bigint NOT NULL,
    awarded timestamp without time zone NOT NULL,
    date_created timestamp without time zone NOT NULL,
    last_updated timestamp without time zone NOT NULL,
    user_id bigint NOT NULL,
    user_notified boolean NOT NULL
);
ALTER TABLE achievement_award OWNER TO volunteers;

--
-- Name: achievement_description; Type: TABLE; Schema: public; Owner: volunteers
--

CREATE TABLE achievement_description (
    id bigint NOT NULL,
    version bigint NOT NULL,
    aggregation_query character varying(10000),
    aggregation_type character varying(255),
    badge character varying(255) NOT NULL,
    code character varying(10000),
    count integer,
    date_created timestamp without time zone NOT NULL,
    description character varying(1000) NOT NULL,
    enabled boolean NOT NULL,
    last_updated timestamp without time zone NOT NULL,
    name character varying(255) NOT NULL,
    search_query character varying(10000),
    type character varying(255) NOT NULL
);
ALTER TABLE achievement_description OWNER TO volunteers;

--
-- Name: collection_event; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE collection_event (
    id bigint NOT NULL,
    version bigint NOT NULL,
    collector character varying(255) NOT NULL,
    collector_normalised character varying(255),
    country character varying(255),
    event_date character varying(255) NOT NULL,
    external_event_id bigint,
    external_locality_id bigint,
    institution character varying(255),
    latitude double precision,
    latitudedms character varying(255) NOT NULL,
    locality character varying(255) NOT NULL,
    longitude double precision,
    longitudedms character varying(255) NOT NULL,
    state character varying(255),
    township character varying(255)
);

--
-- Name: comment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE comment (
    id bigint NOT NULL,
    comment character varying(255),
    field_id bigint,
    relates_to_field integer,
    relates_to_record integer,
    reply_to integer,
    task_id bigint,
    user_id character varying(200) NOT NULL
);

--
-- Name: field; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE field (
    id bigint NOT NULL,
    name character varying(200) NOT NULL,
    record_idx integer,
    superceded boolean NOT NULL,
    task_id bigint,
    transcribed_by_user_id character varying(200) NOT NULL,
    validated_by_user_id character varying(200),
    value text,
    created timestamp without time zone,
    updated timestamp without time zone
);

--
-- Name: forum_message; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE forum_message (
    id bigint NOT NULL,
    version bigint NOT NULL,
    date timestamp without time zone NOT NULL,
    deleted boolean,
    reply_to_id bigint,
    text character varying(16384),
    topic_id bigint NOT NULL,
    user_id bigint NOT NULL
);

--
-- Name: forum_topic; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE forum_topic (
    id bigint NOT NULL,
    version bigint NOT NULL,
    creator_id bigint NOT NULL,
    date_created timestamp without time zone NOT NULL,
    deleted boolean,
    last_reply_date timestamp without time zone,
    locked boolean,
    priority integer,
    sticky boolean,
    title character varying(255) NOT NULL,
    views integer,
    class character varying(255) NOT NULL,
    project_id bigint,
    task_id bigint,
    featured boolean
);

--
-- Name: forum_topic_notification_message; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE forum_topic_notification_message (
    id bigint NOT NULL,
    version bigint NOT NULL,
    message_id bigint NOT NULL,
    topic_id bigint NOT NULL,
    user_id bigint NOT NULL
);

--
-- Name: front_page; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE front_page (
    id bigint NOT NULL,
    version bigint NOT NULL,
    featured_project1_id bigint NOT NULL,
    featured_project2_id bigint NOT NULL,
    featured_project3_id bigint NOT NULL,
    news_body character varying(255),
    news_created timestamp without time zone,
    news_title character varying(100),
    project_of_the_day_id bigint NOT NULL,
    use_global_news_item boolean NOT NULL,
    system_message character varying(255),
    show_achievements boolean,
    enable_task_comments boolean,
    enable_forum boolean,
    number_of_contributors integer DEFAULT 10 NOT NULL
);

--
-- Name: hibernate_sequence; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE hibernate_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

--
-- Name: institution; Type: TABLE; Schema: public; Owner: volunteers
--

CREATE TABLE institution (
    id bigint NOT NULL,
    version integer NOT NULL,
    acronym character varying(255),
    collectory_uid character varying(255),
    contact_email character varying(255),
    contact_name character varying(255),
    contact_phone character varying(255),
    date_created timestamp without time zone NOT NULL,
    description character varying(16384),
    image_caption character varying(255),
    last_updated timestamp without time zone NOT NULL,
    name character varying(255) NOT NULL,
    short_description character varying(512),
    website_url character varying(255),
    disable_news_items boolean DEFAULT false NOT NULL,
    theme_colour character varying(255)
);
ALTER TABLE institution OWNER TO volunteers;

--
-- Name: label; Type: TABLE; Schema: public; Owner: volunteers
--

CREATE TABLE label (
    id bigint NOT NULL,
    version bigint NOT NULL,
    category character varying(255) NOT NULL,
    value character varying(255) NOT NULL
);
ALTER TABLE label OWNER TO volunteers;

--
-- Name: locality; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE locality (
    id bigint NOT NULL,
    version bigint NOT NULL,
    country character varying(255),
    external_locality_id bigint,
    institution_code character varying(255) NOT NULL,
    latitude double precision,
    latitudedms character varying(255),
    locality character varying(255),
    longitude double precision,
    longitudedms character varying(255),
    state character varying(255),
    township character varying(255)
);

--
-- Name: multimedia; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE multimedia (
    id bigint NOT NULL,
    created timestamp without time zone,
    creator character varying(200),
    file_path character varying(200),
    file_path_to_thumbnail character varying(200),
    licence character varying(200),
    mime_type character varying(50),
    task_id bigint
);

--
-- Name: news_item; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE news_item (
    id bigint NOT NULL,
    version bigint NOT NULL,
    body character varying(4000),
    created timestamp without time zone NOT NULL,
    created_by character varying(255) NOT NULL,
    project_id bigint,
    title character varying(255) NOT NULL,
    short_description character varying(255),
    institution_id bigint
);

--
-- Name: picklist; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE picklist (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    field_type_classifier character varying(255)
);

--
-- Name: picklist_item; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE picklist_item (
    id bigint NOT NULL,
    key character varying(1024),
    picklist_id bigint NOT NULL,
    value text NOT NULL,
    institution_code character varying(255),
    index integer DEFAULT 0 NOT NULL
);

--
-- Name: project; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE project (
    id bigint NOT NULL,
    created timestamp without time zone,
    description character varying(3000),
    name character varying(200) NOT NULL,
    template_id bigint,
    banner_image character varying(255),
    tutorial_links character varying(2000),
    show_map boolean,
    disable_news_items boolean,
    featured_image character varying(255),
    featured_label character varying(255),
    featured_owner character varying(255),
    short_description character varying(500),
    leader_icon_index integer,
    featured_image_copyright character varying(255),
    collection_event_lookup_collection_code character varying(255),
    inactive boolean,
    locality_lookup_collection_code character varying(255),
    map_init_latitude double precision,
    map_init_longitude double precision,
    map_init_zoom_level integer,
    picklist_institution_code character varying(255),
    project_type_id bigint,
    harvestable_by_ala boolean DEFAULT true,
    institution_id bigint,
    background_image_attribution character varying(255),
    version integer DEFAULT 0 NOT NULL,
    background_image_overlay_colour character varying(255),
    archived boolean DEFAULT false NOT NULL,
    date_created timestamp without time zone DEFAULT now() NOT NULL,
    last_updated timestamp without time zone DEFAULT now() NOT NULL
);

--
-- Name: project_association; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE project_association (
    id bigint NOT NULL,
    entity_uid character varying(200) NOT NULL,
    project_id bigint NOT NULL
);

--
-- Name: project_forum_watch_list; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE project_forum_watch_list (
    id bigint NOT NULL,
    version bigint NOT NULL,
    project_id bigint NOT NULL
);

--
-- Name: project_forum_watch_list_vp_user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE project_forum_watch_list_vp_user (
    project_forum_watch_list_users_id bigint,
    user_id bigint
);

--
-- Name: project_labels; Type: TABLE; Schema: public; Owner: volunteers
--

CREATE TABLE project_labels (
    label_id bigint NOT NULL,
    project_id bigint NOT NULL
);
ALTER TABLE project_labels OWNER TO volunteers;

--
-- Name: project_staging_profile; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE project_staging_profile (
    id bigint NOT NULL,
    version bigint NOT NULL,
    project_id bigint NOT NULL
);

--
-- Name: project_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE project_type (
    id bigint NOT NULL,
    version bigint NOT NULL,
    description character varying(255),
    label character varying(255) NOT NULL,
    name character varying(255) NOT NULL
);

--
-- Name: role; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE role (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    role character varying(100),
    user_id bigint
);

--
-- Name: setting; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE setting (
    id bigint NOT NULL,
    version bigint NOT NULL,
    comments character varying(255),
    key character varying(255) NOT NULL,
    value text
);

--
-- Name: staging_field_definition; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE staging_field_definition (
    id bigint NOT NULL,
    version bigint NOT NULL,
    field_definition_type character varying(255),
    field_name character varying(255) NOT NULL,
    format character varying(255),
    profile_id bigint NOT NULL,
    record_index integer
);

--
-- Name: task; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE task (
    id bigint NOT NULL,
    created timestamp without time zone,
    external_identifier character varying(255),
    external_url character varying(255),
    fully_transcribed_by character varying(255),
    fully_validated_by character varying(255),
    project_id bigint NOT NULL,
    viewed integer,
    is_valid boolean,
    date_fully_transcribed timestamp without time zone,
    date_fully_validated timestamp without time zone,
    date_last_updated timestamp without time zone,
    last_viewed bigint,
    last_viewed_by character varying(255),
    fully_transcribed_ip_address character varying(255),
    transcribeduuid uuid,
    validateduuid uuid
);

--
-- Name: task_comment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE task_comment (
    id bigint NOT NULL,
    version bigint NOT NULL,
    comment character varying(4096) NOT NULL,
    date timestamp without time zone NOT NULL,
    task_id bigint NOT NULL,
    user_id bigint NOT NULL
);

--
-- Name: template; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE template (
    id bigint NOT NULL,
    author character varying(200),
    field_order character varying(255) NOT NULL,
    name character varying(200) NOT NULL,
    view_name character varying(255)
);

--
-- Name: template_field; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE template_field (
    id bigint NOT NULL,
    category character varying(255) NOT NULL,
    default_value character varying(200),
    field_type character varying(255) NOT NULL,
    help_text character varying(2000),
    label character varying(255),
    mandatory boolean,
    multi_value boolean,
    template_id bigint,
    type character varying(255) NOT NULL,
    validation_rule character varying(255),
    display_order integer,
    layout_class character varying(255),
    field_type_classifier character varying(255)
);

--
-- Name: template_view_params; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE template_view_params (
    view_params bigint,
    view_params_idx character varying(255),
    view_params_elt character varying(255) NOT NULL
);

--
-- Name: user_activity; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE user_activity (
    id bigint NOT NULL,
    version bigint NOT NULL,
    last_request character varying(4096) NOT NULL,
    time_first_activity timestamp without time zone NOT NULL,
    time_last_activity timestamp without time zone NOT NULL,
    user_id character varying(255) NOT NULL,
    ip character varying(255)
);

--
-- Name: user_forum_watch_list; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE user_forum_watch_list (
    id bigint NOT NULL,
    version bigint NOT NULL,
    user_id bigint NOT NULL
);

--
-- Name: user_forum_watch_list_forum_topic; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE user_forum_watch_list_forum_topic (
    user_forum_watch_list_topics_id bigint,
    forum_topic_id bigint
);

--
-- Name: user_role; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE user_role (
    id bigint NOT NULL,
    version bigint NOT NULL,
    project_id bigint,
    role_id bigint NOT NULL,
    user_id bigint NOT NULL,
    institution_id bigint
);

--
-- Name: validation_rule; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE validation_rule (
    id bigint NOT NULL,
    version bigint NOT NULL,
    description character varying(255),
    message character varying(255),
    name character varying(255) NOT NULL,
    regular_expression character varying(255),
    test_empty_values boolean,
    validation_type character varying(255)
);

--
-- Name: viewed_task; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE viewed_task (
    id bigint NOT NULL,
    date_created timestamp without time zone,
    last_updated timestamp without time zone,
    last_view bigint,
    number_of_views integer,
    task_id bigint,
    user_id character varying(255)
);

--
-- Name: vp_user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE vp_user (
    id bigint NOT NULL,
    created timestamp without time zone NOT NULL,
    display_name character varying(255) NOT NULL,
    transcribed_count integer,
    user_id character varying(200) NOT NULL,
    validated_count integer,
    email character varying(200) NOT NULL,
    organisation character varying(255)
);

--
-- Name: achievement_award achievement_award_pkey; Type: CONSTRAINT; Schema: public; Owner: volunteers
--

ALTER TABLE ONLY achievement_award
    ADD CONSTRAINT achievement_award_pkey PRIMARY KEY (id);
--
-- Name: achievement_award achievement_award_user_id_achievement_id_key; Type: CONSTRAINT; Schema: public; Owner: volunteers
--

ALTER TABLE ONLY achievement_award
    ADD CONSTRAINT achievement_award_user_id_achievement_id_key UNIQUE (user_id, achievement_id);
--
-- Name: achievement_description achievement_description_pkey; Type: CONSTRAINT; Schema: public; Owner: volunteers
--

ALTER TABLE ONLY achievement_description
    ADD CONSTRAINT achievement_description_pkey PRIMARY KEY (id);
--
-- Name: achievement achievement_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY achievement
    ADD CONSTRAINT achievement_pkey PRIMARY KEY (id);
--
-- Name: collection_event collection_event_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY collection_event
    ADD CONSTRAINT collection_event_pkey PRIMARY KEY (id);
--
-- Name: comment comment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY comment
    ADD CONSTRAINT comment_pkey PRIMARY KEY (id);
--
-- Name: field field_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY field
    ADD CONSTRAINT field_pkey PRIMARY KEY (id);
--
-- Name: forum_message forum_message_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY forum_message
    ADD CONSTRAINT forum_message_pkey PRIMARY KEY (id);
--
-- Name: forum_topic_notification_message forum_topic_notification_message_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY forum_topic_notification_message
    ADD CONSTRAINT forum_topic_notification_message_pkey PRIMARY KEY (id);
--
-- Name: forum_topic forum_topic_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY forum_topic
    ADD CONSTRAINT forum_topic_pkey PRIMARY KEY (id);
--
-- Name: front_page front_page_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY front_page
    ADD CONSTRAINT front_page_pkey PRIMARY KEY (id);
--
-- Name: institution institution_pkey; Type: CONSTRAINT; Schema: public; Owner: volunteers
--

ALTER TABLE ONLY institution
    ADD CONSTRAINT institution_pkey PRIMARY KEY (id);
--
-- Name: label label_pkey; Type: CONSTRAINT; Schema: public; Owner: volunteers
--

ALTER TABLE ONLY label
    ADD CONSTRAINT label_pkey PRIMARY KEY (id);
--
-- Name: label label_value_category_key; Type: CONSTRAINT; Schema: public; Owner: volunteers
--

ALTER TABLE ONLY label
    ADD CONSTRAINT label_value_category_key UNIQUE (value, category);
--
-- Name: locality locality_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY locality
    ADD CONSTRAINT locality_pkey PRIMARY KEY (id);
--
-- Name: multimedia multimedia_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY multimedia
    ADD CONSTRAINT multimedia_pkey PRIMARY KEY (id);
--
-- Name: news_item news_item_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY news_item
    ADD CONSTRAINT news_item_pkey PRIMARY KEY (id);
--
-- Name: picklist_item picklist_item_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY picklist_item
    ADD CONSTRAINT picklist_item_pkey PRIMARY KEY (id);
--
-- Name: picklist picklist_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY picklist
    ADD CONSTRAINT picklist_pkey PRIMARY KEY (id);
--
-- Name: project_association project_association_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY project_association
    ADD CONSTRAINT project_association_pkey PRIMARY KEY (id);
--
-- Name: project_forum_watch_list project_forum_watch_list_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY project_forum_watch_list
    ADD CONSTRAINT project_forum_watch_list_pkey PRIMARY KEY (id);
--
-- Name: project_labels project_labels_pkey; Type: CONSTRAINT; Schema: public; Owner: volunteers
--

ALTER TABLE ONLY project_labels
    ADD CONSTRAINT project_labels_pkey PRIMARY KEY (project_id, label_id);
--
-- Name: project project_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY project
    ADD CONSTRAINT project_pkey PRIMARY KEY (id);
--
-- Name: project_staging_profile project_staging_profile_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY project_staging_profile
    ADD CONSTRAINT project_staging_profile_pkey PRIMARY KEY (id);
--
-- Name: project_type project_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY project_type
    ADD CONSTRAINT project_type_pkey PRIMARY KEY (id);
--
-- Name: role role_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY role
    ADD CONSTRAINT role_pkey PRIMARY KEY (id);
--
-- Name: setting setting_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY setting
    ADD CONSTRAINT setting_pkey PRIMARY KEY (id);
--
-- Name: staging_field_definition staging_field_definition_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY staging_field_definition
    ADD CONSTRAINT staging_field_definition_pkey PRIMARY KEY (id);
--
-- Name: task_comment task_comment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY task_comment
    ADD CONSTRAINT task_comment_pkey PRIMARY KEY (id);
--
-- Name: task task_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY task
    ADD CONSTRAINT task_pkey PRIMARY KEY (id);
--
-- Name: template_field template_field_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY template_field
    ADD CONSTRAINT template_field_pkey PRIMARY KEY (id);
--
-- Name: template template_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY template
    ADD CONSTRAINT template_pkey PRIMARY KEY (id);
--
-- Name: achievement_award unique_achievement_id; Type: CONSTRAINT; Schema: public; Owner: volunteers
--

ALTER TABLE ONLY achievement_award
    ADD CONSTRAINT unique_achievement_id UNIQUE (user_id, achievement_id);
--
-- Name: label unique_category; Type: CONSTRAINT; Schema: public; Owner: volunteers
--

ALTER TABLE ONLY label
    ADD CONSTRAINT unique_category UNIQUE (value, category);
--
-- Name: user_activity user_activity_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY user_activity
    ADD CONSTRAINT user_activity_pkey PRIMARY KEY (id);
--
-- Name: user_forum_watch_list user_forum_watch_list_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY user_forum_watch_list
    ADD CONSTRAINT user_forum_watch_list_pkey PRIMARY KEY (id);
--
-- Name: user_role user_role_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY user_role
    ADD CONSTRAINT user_role_pkey PRIMARY KEY (id);
--
-- Name: validation_rule validation_rule_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY validation_rule
    ADD CONSTRAINT validation_rule_name_key UNIQUE (name);
--
-- Name: validation_rule validation_rule_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY validation_rule
    ADD CONSTRAINT validation_rule_pkey PRIMARY KEY (id);
--
-- Name: viewed_task viewed_task_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY viewed_task
    ADD CONSTRAINT viewed_task_pkey PRIMARY KEY (id);
--
-- Name: vp_user vp_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vp_user
    ADD CONSTRAINT vp_user_pkey PRIMARY KEY (id);
--
-- Name: collector_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX collector_idx ON collection_event USING btree (collector);
--
-- Name: event_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX event_date_idx ON collection_event USING btree (event_date);
--
-- Name: external_event_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX external_event_id_idx ON collection_event USING btree (external_event_id);
--
-- Name: external_event_id_inst_code_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX external_event_id_inst_code_idx ON collection_event USING btree (external_event_id, institution);
--
-- Name: external_locality_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX external_locality_id_idx ON collection_event USING btree (external_locality_id);
--
-- Name: external_locality_inst_code_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX external_locality_inst_code_idx ON collection_event USING btree (external_locality_id, institution);
--
-- Name: field_name_index_superceeded_task_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX field_name_index_superceeded_task_idx ON field USING btree (name, record_idx, superceded, task_id);
--
-- Name: field_task_superceded_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX field_task_superceded_idx ON field USING btree (task_id, superceded);
--
-- Name: field_transcribed_by_user_id_superceded_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX field_transcribed_by_user_id_superceded_idx ON field USING btree (transcribed_by_user_id, superceded);
--
-- Name: fieldnameidx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fieldnameidx ON field USING btree (name);
--
-- Name: fieldupdatedidx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fieldupdatedidx ON field USING btree (updated);
--
-- Name: institution_code_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX institution_code_idx ON collection_event USING btree (institution);
--
-- Name: picklist_item_picklist_id_institution_code_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX picklist_item_picklist_id_institution_code_idx ON picklist_item USING btree (picklist_id, institution_code);
--
-- Name: viewed_task_task_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX viewed_task_task_id_idx ON viewed_task USING btree (task_id);
--
-- Name: news_item fk11ed74ff94a5f91a; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY news_item
    ADD CONSTRAINT fk11ed74ff94a5f91a FOREIGN KEY (institution_id) REFERENCES institution(id);
--
-- Name: news_item fk11ed74ffd7b4217a; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY news_item
    ADD CONSTRAINT fk11ed74ffd7b4217a FOREIGN KEY (project_id) REFERENCES project(id);
--
-- Name: user_role fk143bf46a5f96c37a; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY user_role
    ADD CONSTRAINT fk143bf46a5f96c37a FOREIGN KEY (user_id) REFERENCES vp_user(id);
--
-- Name: user_role fk143bf46a94a5f91a; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY user_role
    ADD CONSTRAINT fk143bf46a94a5f91a FOREIGN KEY (institution_id) REFERENCES institution(id);
--
-- Name: user_role fk143bf46aba6bff9a; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY user_role
    ADD CONSTRAINT fk143bf46aba6bff9a FOREIGN KEY (role_id) REFERENCES role(id);
--
-- Name: user_role fk143bf46ad7b4217a; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY user_role
    ADD CONSTRAINT fk143bf46ad7b4217a FOREIGN KEY (project_id) REFERENCES project(id);
--
-- Name: achievement_award fk19b30d4d107a3b18; Type: FK CONSTRAINT; Schema: public; Owner: volunteers
--

ALTER TABLE ONLY achievement_award
    ADD CONSTRAINT fk19b30d4d107a3b18 FOREIGN KEY (achievement_id) REFERENCES achievement_description(id);
--
-- Name: achievement_award fk19b30d4d5f96c37a; Type: FK CONSTRAINT; Schema: public; Owner: volunteers
--

ALTER TABLE ONLY achievement_award
    ADD CONSTRAINT fk19b30d4d5f96c37a FOREIGN KEY (user_id) REFERENCES vp_user(id);
--
-- Name: forum_topic_notification_message fk1e5043a15f96c37a; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY forum_topic_notification_message
    ADD CONSTRAINT fk1e5043a15f96c37a FOREIGN KEY (user_id) REFERENCES vp_user(id);
--
-- Name: forum_topic_notification_message fk1e5043a1961b1d99; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY forum_topic_notification_message
    ADD CONSTRAINT fk1e5043a1961b1d99 FOREIGN KEY (message_id) REFERENCES forum_message(id);
--
-- Name: forum_topic_notification_message fk1e5043a1ed2a7059; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY forum_topic_notification_message
    ADD CONSTRAINT fk1e5043a1ed2a7059 FOREIGN KEY (topic_id) REFERENCES forum_topic(id);
--
-- Name: viewed_task fk2b205ee0cbab13a; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY viewed_task
    ADD CONSTRAINT fk2b205ee0cbab13a FOREIGN KEY (task_id) REFERENCES task(id) ON DELETE CASCADE;
--
-- Name: project_labels fk2cd313e52dcfe79a; Type: FK CONSTRAINT; Schema: public; Owner: volunteers
--

ALTER TABLE ONLY project_labels
    ADD CONSTRAINT fk2cd313e52dcfe79a FOREIGN KEY (label_id) REFERENCES label(id);
--
-- Name: project_labels fk2cd313e5d7b4217a; Type: FK CONSTRAINT; Schema: public; Owner: volunteers
--

ALTER TABLE ONLY project_labels
    ADD CONSTRAINT fk2cd313e5d7b4217a FOREIGN KEY (project_id) REFERENCES project(id);
--
-- Name: role fk3580765f96c37a; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY role
    ADD CONSTRAINT fk3580765f96c37a FOREIGN KEY (user_id) REFERENCES vp_user(id);
--
-- Name: task fk363585d7b4217a; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY task
    ADD CONSTRAINT fk363585d7b4217a FOREIGN KEY (project_id) REFERENCES project(id) ON DELETE CASCADE;
--
-- Name: forum_message fk384182e94272910; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY forum_message
    ADD CONSTRAINT fk384182e94272910 FOREIGN KEY (reply_to_id) REFERENCES forum_message(id);
--
-- Name: forum_message fk384182e95f96c37a; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY forum_message
    ADD CONSTRAINT fk384182e95f96c37a FOREIGN KEY (user_id) REFERENCES vp_user(id);
--
-- Name: forum_message fk384182e9ed2a7059; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY forum_message
    ADD CONSTRAINT fk384182e9ed2a7059 FOREIGN KEY (topic_id) REFERENCES forum_topic(id);
--
-- Name: comment fk38a5ee5f6ae761da; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY comment
    ADD CONSTRAINT fk38a5ee5f6ae761da FOREIGN KEY (field_id) REFERENCES field(id);
--
-- Name: comment fk38a5ee5fcbab13a; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY comment
    ADD CONSTRAINT fk38a5ee5fcbab13a FOREIGN KEY (task_id) REFERENCES task(id);
--
-- Name: multimedia fk4b39f64bcbab13a; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY multimedia
    ADD CONSTRAINT fk4b39f64bcbab13a FOREIGN KEY (task_id) REFERENCES task(id) ON DELETE CASCADE;
--
-- Name: user_forum_watch_list fk5a456de05f96c37a; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY user_forum_watch_list
    ADD CONSTRAINT fk5a456de05f96c37a FOREIGN KEY (user_id) REFERENCES vp_user(id);
--
-- Name: field fk5cea0facbab13a; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY field
    ADD CONSTRAINT fk5cea0facbab13a FOREIGN KEY (task_id) REFERENCES task(id);
--
-- Name: user_forum_watch_list_forum_topic fk60309cb2cafae2ae; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY user_forum_watch_list_forum_topic
    ADD CONSTRAINT fk60309cb2cafae2ae FOREIGN KEY (user_forum_watch_list_topics_id) REFERENCES user_forum_watch_list(id);
--
-- Name: user_forum_watch_list_forum_topic fk60309cb2d8a449b7; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY user_forum_watch_list_forum_topic
    ADD CONSTRAINT fk60309cb2d8a449b7 FOREIGN KEY (forum_topic_id) REFERENCES forum_topic(id);
--
-- Name: task_comment fk61f475a55f96c37a; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY task_comment
    ADD CONSTRAINT fk61f475a55f96c37a FOREIGN KEY (user_id) REFERENCES vp_user(id);
--
-- Name: task_comment fk61f475a5cbab13a; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY task_comment
    ADD CONSTRAINT fk61f475a5cbab13a FOREIGN KEY (task_id) REFERENCES task(id);
--
-- Name: achievement fk682a8f2f5f96c37a; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY achievement
    ADD CONSTRAINT fk682a8f2f5f96c37a FOREIGN KEY (user_id) REFERENCES vp_user(id);
--
-- Name: project_staging_profile fk80842c7fd7b4217a; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY project_staging_profile
    ADD CONSTRAINT fk80842c7fd7b4217a FOREIGN KEY (project_id) REFERENCES project(id);
--
-- Name: project_association fk98f8a85bd7b4217a; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY project_association
    ADD CONSTRAINT fk98f8a85bd7b4217a FOREIGN KEY (project_id) REFERENCES project(id);
--
-- Name: project_forum_watch_list_vp_user fka67fc3435f96c37a; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY project_forum_watch_list_vp_user
    ADD CONSTRAINT fka67fc3435f96c37a FOREIGN KEY (user_id) REFERENCES vp_user(id);
--
-- Name: project_forum_watch_list_vp_user fka67fc34381e253c4; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY project_forum_watch_list_vp_user
    ADD CONSTRAINT fka67fc34381e253c4 FOREIGN KEY (project_forum_watch_list_users_id) REFERENCES project_forum_watch_list(id);
--
-- Name: project_forum_watch_list fkb168d452d7b4217a; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY project_forum_watch_list
    ADD CONSTRAINT fkb168d452d7b4217a FOREIGN KEY (project_id) REFERENCES project(id);
--
-- Name: template_field fkb2950cf5ad0c811a; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY template_field
    ADD CONSTRAINT fkb2950cf5ad0c811a FOREIGN KEY (template_id) REFERENCES template(id);
--
-- Name: staging_field_definition fkc065d13ce93f3e38; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY staging_field_definition
    ADD CONSTRAINT fkc065d13ce93f3e38 FOREIGN KEY (profile_id) REFERENCES project_staging_profile(id);
--
-- Name: picklist_item fke7584b1388ea2efa; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY picklist_item
    ADD CONSTRAINT fke7584b1388ea2efa FOREIGN KEY (picklist_id) REFERENCES picklist(id) ON DELETE CASCADE;
--
-- Name: front_page fkecadaee51590ca67; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY front_page
    ADD CONSTRAINT fkecadaee51590ca67 FOREIGN KEY (project_of_the_day_id) REFERENCES project(id);
--
-- Name: front_page fkecadaee5c9f8b96a; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY front_page
    ADD CONSTRAINT fkecadaee5c9f8b96a FOREIGN KEY (featured_project1_id) REFERENCES project(id);
--
-- Name: front_page fkecadaee5c9f92dc9; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY front_page
    ADD CONSTRAINT fkecadaee5c9f92dc9 FOREIGN KEY (featured_project2_id) REFERENCES project(id);
--
-- Name: front_page fkecadaee5c9f9a228; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY front_page
    ADD CONSTRAINT fkecadaee5c9f9a228 FOREIGN KEY (featured_project3_id) REFERENCES project(id);
--
-- Name: project fked904b1994a5f91a; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY project
    ADD CONSTRAINT fked904b1994a5f91a FOREIGN KEY (institution_id) REFERENCES institution(id);
--
-- Name: project fked904b19ad0c811a; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY project
    ADD CONSTRAINT fked904b19ad0c811a FOREIGN KEY (template_id) REFERENCES template(id);
--
-- Name: project fked904b19cc64c56d; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY project
    ADD CONSTRAINT fked904b19cc64c56d FOREIGN KEY (project_type_id) REFERENCES project_type(id);
--
-- Name: forum_topic fkee14a091ba92c779; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY forum_topic
    ADD CONSTRAINT fkee14a091ba92c779 FOREIGN KEY (creator_id) REFERENCES vp_user(id);
--
-- Name: forum_topic fkee14a091cbab13a; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY forum_topic
    ADD CONSTRAINT fkee14a091cbab13a FOREIGN KEY (task_id) REFERENCES task(id);
--
-- Name: forum_topic fkee14a091d7b4217a; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY forum_topic
    ADD CONSTRAINT fkee14a091d7b4217a FOREIGN KEY (project_id) REFERENCES project(id);
--
-- PostgreSQL database dump complete
--

