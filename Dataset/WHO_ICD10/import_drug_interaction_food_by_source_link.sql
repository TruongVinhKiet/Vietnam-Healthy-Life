BEGIN;
CREATE TEMP TABLE tmp_drug_interaction_food (
    source_link text,
    interaction_type varchar(50),
    interacts_with varchar(255),
    severity varchar(50),
    description_en text,
    management_en text
);

\copy tmp_drug_interaction_food (source_link, interaction_type, interacts_with, severity, description_en, management_en) FROM 'D:/App/new/Dataset/WHO_ICD10/drug_interaction_food_by_source_link.csv' CSV HEADER;

SELECT COUNT(*) AS missing_drugs FROM tmp_drug_interaction_food t LEFT JOIN drug d ON d.source_link = t.source_link WHERE d.drug_id IS NULL;

DELETE FROM drug_interaction di
USING tmp_drug_interaction_food t
JOIN drug d ON d.source_link = t.source_link
WHERE di.drug_id = d.drug_id
  AND di.interaction_type = t.interaction_type
  AND di.interacts_with = t.interacts_with;

INSERT INTO drug_interaction (drug_id, interaction_type, interacts_with, severity, description_en, management_en)
SELECT d.drug_id, t.interaction_type, t.interacts_with, t.severity, t.description_en, t.management_en
FROM tmp_drug_interaction_food t
JOIN drug d ON d.source_link = t.source_link;

COMMIT;
