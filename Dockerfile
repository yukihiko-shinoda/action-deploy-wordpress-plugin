FROM futureys/deploy-wordpress-plugin:2.3.0
RUN mv /bin/entrypoint /bin/entrypoint-deploy-wordpress-plugin
COPY entrypoint.sh /bin/entrypoint
RUN chmod +x /bin/entrypoint
