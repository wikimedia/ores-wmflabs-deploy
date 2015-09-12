revert_window = 48 # hours
revert_radius = 3  # revisions

enwiki = https://en.wikipedia.org
fawiki = https://fa.wikipedia.org
frwiki = https://fr.wikipedia.org
ptwiki = https://pt.wikipedia.org
trwiki = https://tr.wikipedia.org
idwiki = https://id.wikipedia.org
eswiki = https://es.wikipedia.org

all_models:
	make models/enwiki.reverted.linear_svc.model & \
	make models/enwiki.wp10.rf.model & \
	make models/fawiki.reverted.linear_svc.model & \
	make models/frwiki.reverted.linear_svc.model & \
	make models/ptwiki.reverted.linear_svc.model & \
	make models/trwiki.reverted.linear_svc.model & \
	make models/idwiki.reverted.linear_svc.model & \
	make models/eswiki.reverted.linear_svc.model &


########################### English Wikipedia ##################################
datasets/enwiki.rev_reverted.20k.tsv: datasets/enwiki.rev_pages.20k.tsv
	cat datasets/enwiki.rev_pages.20k.tsv | \
	ores label_reverted \
		--api=$(enwiki_api) \
		--revert-window=$(revert_window) \
		--revert-radius=$(revert_radius) > \
	datasets/enwiki.rev_reverted.20k.tsv

datasets/enwiki.features_reverted.20k.tsv: datasets/enwiki.rev_reverted.20k.tsv
	cat datasets/enwiki.rev_reverted.20k.tsv | \
	revscoring extract_features \
		feature_lists.enwiki.damaging \
		--host=$(enwiki) > \
	datasets/enwiki.features_reverted.20k.tsv

models/enwiki.reverted.linear_svc.model: \
		datasets/enwiki.features_reverted.20k.tsv
	cat datasets/enwiki.features_reverted.20k.tsv | \
	revscoring train_test \
		revscoring.scorer_models.LinearSVCModel \
		feature_lists.enwiki.damaging \
		--label-type=bool \
		--version=0.3.0 > \
	models/enwiki.reverted.linear_svc.model

datasets/enwiki.features_wp10.30k.tsv: datasets/enwiki.rev_wp10.30k.tsv
	cat datasets/enwiki.rev_wp10.30k.tsv | \
	revscoring extract_features \
		feature_lists.enwiki.wp10 \
		--host=$(enwiki) > \
	datasets/enwiki.features_wp10.30k.tsv

models/enwiki.wp10.rf.model: datasets/enwiki.features_wp10.30k.tsv
	cat datasets/enwiki.features_wp10.30k.tsv | \
	grep -v -P "\tA" | \
	revscoring train_test \
		revscoring.scorer_models.RFModel \
		feature_lists.enwiki.wp10 \
		-p 'n_estimators=501' \
		-p 'min_samples_leaf=8' \
		--version=0.2.0 > \
	models/enwiki.wp10.rf.model


###################### Persian Wikipedia ####################################
datasets/fawiki.rev_reverted.20k.tsv: datasets/fawiki.rev_pages.20k.tsv
	cat datasets/fawiki.rev_pages.20k.tsv | \
	ores label_reverted \
		--host=$(fawiki) \
		--revert-window=$(revert_window) \
		--revert-radius=$(revert_radius) > \
	datasets/fawiki.rev_reverted.20k.tsv

datasets/fawiki.features_reverted.20k.tsv: datasets/fawiki.rev_reverted.20k.tsv
	cat datasets/fawiki.rev_reverted.20k.tsv | \
	revscoring extract_features \
		feature_lists.fawiki.damaging \
		--host=$(fawiki) > \
	datasets/fawiki.features_reverted.20k.tsv

models/fawiki.reverted.linear_svc.model: \
		datasets/fawiki.features_reverted.20k.tsv
	cat datasets/fawiki.features_reverted.20k.tsv | \
	revscoring train_test \
		revscoring.scorer_models.LinearSVCModel \
		feature_lists.fawiki.damaging \
		--label-type=bool \
		--version=0.3.0 > \
	models/fawiki.reverted.linear_svc.model


###################### French Wikipedia ####################################
datasets/frwiki.rev_reverted.20k.tsv: datasets/frwiki.rev_pages.20k.tsv
	cat datasets/frwiki.rev_pages.20k.tsv | \
	ores label_reverted \
		--host=$(frwiki) \
		--revert-window=$(revert_window) \
		--revert-radius=$(revert_radius) > \
	datasets/frwiki.rev_reverted.20k.tsv

datasets/frwiki.features_reverted.20k.tsv: datasets/frwiki.rev_reverted.20k.tsv
	cat datasets/frwiki.rev_reverted.20k.tsv | \
	revscoring extract_features \
		feature_lists.frwiki.damaging \
		--host=$(frwiki) > \
	datasets/frwiki.features_reverted.20k.tsv

models/frwiki.reverted.linear_svc.model: \
		datasets/frwiki.features_reverted.20k.tsv
	cat datasets/frwiki.features_reverted.20k.tsv | \
	revscoring train_test \
		revscoring.scorer_models.LinearSVCModel \
		feature_lists.frwiki.damaging \
		--label-type=bool \
		--version=0.3.0 > \
	models/frwiki.reverted.linear_svc.model

###################### Portuguese Wikipedia ####################################
datasets/ptwiki.rev_reverted.20k.tsv: datasets/ptwiki.rev_pages.20k.tsv
	cat datasets/ptwiki.rev_pages.20k.tsv | \
	ores label_reverted \
		--host=$(ptwiki) \
		--revert-window=$(revert_window) \
		--revert-radius=$(revert_radius) > \
	datasets/ptwiki.rev_reverted.20k.tsv

datasets/ptwiki.features_reverted.20k.tsv: datasets/ptwiki.rev_reverted.20k.tsv
	cat datasets/ptwiki.rev_reverted.20k.tsv | \
	revscoring extract_features \
		feature_lists.ptwiki.damaging \
		--host=$(ptwiki) > \
	datasets/ptwiki.features_reverted.20k.tsv

models/ptwiki.reverted.linear_svc.model: \
		datasets/ptwiki.features_reverted.20k.tsv
	cat datasets/ptwiki.features_reverted.20k.tsv | \
	revscoring train_test \
		revscoring.scorer_models.LinearSVCModel \
		feature_lists.ptwiki.damaging \
		--label-type=bool \
		--version=0.3.0 > \
	models/ptwiki.reverted.linear_svc.model


######################### Turkish Wikipedia ####################################
datasets/trwiki.rev_reverted.20k.tsv: datasets/trwiki.rev_pages.20k.tsv
	cat datasets/trwiki.rev_pages.20k.tsv | \
	ores label_reverted \
		--host=$(trwiki) \
		--revert-window=$(revert_window) \
		--revert-radius=$(revert_radius) > \
	datasets/trwiki.rev_reverted.20k.tsv

datasets/trwiki.features_reverted.20k.tsv: datasets/trwiki.rev_reverted.20k.tsv
	cat datasets/trwiki.rev_reverted.20k.tsv | \
	revscoring extract_features \
		feature_lists.trwiki.damaging \
		--host=$(trwiki) > \
	datasets/trwiki.features_reverted.20k.tsv

models/trwiki.reverted.linear_svc.model: \
		datasets/trwiki.features_reverted.20k.tsv
	cat datasets/trwiki.features_reverted.20k.tsv | \
	revscoring train_test \
		revscoring.scorer_models.LinearSVCModel \
		feature_lists.trwiki.damaging \
		--label-type=bool \
		--version=0.3.0 > \
	models/trwiki.reverted.linear_svc.model


######################### Indonesian Wikipedia #################################
datasets/idwiki.rev_reverted.20k.tsv: datasets/idwiki.rev_pages.20k.tsv
	cat datasets/idwiki.rev_pages.20k.tsv | \
	ores label_reverted \
		--host=$(idwiki) \
		--revert-window=$(revert_window) \
		--revert-radius=$(revert_radius) > \
	datasets/idwiki.rev_reverted.20k.tsv

datasets/idwiki.features_reverted.20k.tsv: datasets/idwiki.rev_reverted.20k.tsv
	cat datasets/idwiki.rev_reverted.20k.tsv | \
	revscoring extract_features \
		feature_lists.idwiki.damaging \
		--host=$(idwiki) > \
	datasets/idwiki.features_reverted.20k.tsv

models/idwiki.reverted.linear_svc.model: \
		datasets/idwiki.features_reverted.20k.tsv
	cat datasets/idwiki.features_reverted.20k.tsv | \
	revscoring train_test \
		revscoring.scorer_models.LinearSVCModel \
		feature_lists.idwiki.damaging \
		--label-type=bool \
		--version=0.3.0 > \
	models/idwiki.reverted.linear_svc.model


############################ Spanish Wikipedia #################################
datasets/eswiki.rev_reverted.20k.tsv: datasets/eswiki.rev_pages.20k.tsv
	cat datasets/eswiki.rev_pages.20k.tsv | \
	ores label_reverted \
		--host=$(eswiki) \
		--revert-window=$(revert_window) \
		--revert-radius=$(revert_radius) > \
	datasets/eswiki.rev_reverted.20k.tsv

datasets/eswiki.features_reverted.20k.tsv: datasets/eswiki.rev_reverted.20k.tsv
	cat datasets/eswiki.rev_reverted.20k.tsv | \
	revscoring extract_features \
		feature_lists.eswiki.damaging \
		--host=$(eswiki) > \
	datasets/eswiki.features_reverted.20k.tsv

models/eswiki.reverted.linear_svc.model: \
		datasets/eswiki.features_reverted.20k.tsv
	cat datasets/eswiki.features_reverted.20k.tsv | \
	revscoring train_test \
		revscoring.scorer_models.LinearSVCModel \
		feature_lists.eswiki.damaging \
		--label-type=bool \
		--version=0.3.0 > \
	models/eswiki.reverted.linear_svc.model
