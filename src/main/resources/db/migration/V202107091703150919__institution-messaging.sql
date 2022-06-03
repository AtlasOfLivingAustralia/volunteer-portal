-- Institution Messaging

create table if not exists message (
    id bigint NOT NULL,
    version bigint NOT NULL,
    subject character varying(255) NOT NULL,
    body character varying(4000),
    date_created timestamp without time zone DEFAULT now() NOT NULL,
    created_by_id bigint NOT NULL,
    institution_id bigint NOT NULL,
    date_last_updated timestamp without time zone DEFAULT now(),
    last_updated_by_id bigint,
    approved boolean DEFAULT false,
    date_sent timestamp without time zone DEFAULT now(),
    include_contact boolean DEFAULT false,
    approved_by_id bigint,
    PRIMARY KEY(id),
    FOREIGN KEY (institution_id) references institution(id),
    FOREIGN KEY (created_by_id) references vp_user(id),
    FOREIGN KEY (last_updated_by_id) references vp_user(id),
    FOREIGN KEY (approved_by_id) references vp_user(id)
);

create table if not exists message_recipient (
    id bigint NOT NULL,
    message_id bigint not null,
    recipient_user_id bigint,
    recipient_project_id bigint,
    recipient_institution_id bigint,
    primary key(id),
    FOREIGN KEY (recipient_user_id) references vp_user(id),
    FOREIGN KEY (recipient_project_id) references project(id),
    FOREIGN KEY (recipient_institution_id) references institution(id),
    foreign key (message_id) references message(id)
);

create table if not exists message_recipient_audit (
    id bigint NOT NULL,
    message_id bigint NOT NULL,
    recipient_user_id bigint NOT NULL,
    date_sent timestamp without time zone DEFAULT now() NOT NULL,
    send_status integer DEFAULT 0 NOT NULL,
    primary key(id),
    foreign key (message_id) references message(id),
    FOREIGN KEY (recipient_user_id) references vp_user(id)
);

create table if not exists message_user_optout (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    date_created timestamp without time zone DEFAULT now() NOT NULL,
    primary key(id),
    foreign key (user_id) references vp_user(id)
);