FROM futureys/deploy-wordpress-plugin:2.1.1
RUN mv /bin/entrypoint /bin/entrypoint-deploy-wordpress-plugin
COPY entrypoint.sh /bin/entrypoint
RUN chmod +x /bin/entrypoint
