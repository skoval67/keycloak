include .env

.PHONY: all

all: build_infra run_playbook

init:
	@cd ansible; \
		python3 -m venv .venv; \
		. .venv/bin/activate; \
		pip install -r requirements.txt
	@cd terraform;\
		terraform init -backend-config="access_key=${ACCESS_KEY}" -backend-config="secret_key=${SECRET_KEY}"

destroy:
	@cd terraform;\
		export TF_VAR_MY_IP="$$(curl -s https://ident.me)/32";\
		terraform destroy

build_infra:
	@cd terraform;\
		export TF_VAR_MY_IP="$$(curl -s https://ident.me)/32";\
		terraform apply -auto-approve;\
		for server in $$(yc compute instance list --format json | jq -r .[].name); do yc compute instance update $$server --service-account-name terraform; done

run_playbook:
	@cd ansible; \
	    . .venv/bin/activate; \
		ansible-playbook -b playbook.yml -e POSTGRES_PASSWORD=${POSTGRES_PASSWORD} -e KEYCLOAK_ADMIN_PASSWORD=${KEYCLOAK_ADMIN_PASSWORD} \
			-e hostname=${HOSTNAME}
