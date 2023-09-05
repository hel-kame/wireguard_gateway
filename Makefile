docker:
	docker build -t starknode/nginx_rp:latest ./src/nginx/
	docker build -t starknode/wireguard-instance:latest ./src/wg_instance/
	docker build -t starknode/wireguard_client:latest ./src/wg_client/
	docker build -t starknode/wireguard_link:latest ./src/script_link/

setup:
	docker network create gateway

gateway: docker
	docker run --network gateway --restart unless-stopped -p 80:80 -p 443:443 -e NGINX_ENVSUBST_OUTPUT_DIR=/etc/nginx -it -d starknode/nginx_rp:latest

link:
	docker run -e SSH_AGENT_PID=$$SSH_AGENT_PID -e SSH_AUTH_SOCK=$$SSH_AUTH_SOCK -v $$SSH_AUTH_SOCK:$$SSH_AUTH_SOCK --rm -it starknode/wireguard_link:latest $(GATEWAY) $(FQDN) $(EXPOSE)

.PHONY: docker link setup gateway
