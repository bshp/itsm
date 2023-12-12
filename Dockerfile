FROM jetbrains/youtrack:2023.3.21798
    
LABEL org.opencontainers.image.authors="jason.everling@gmail.com"
    
COPY ./src/ ./

RUN set -eux; \
    chown -R root:root /usr/local/bin; \
    chmod -R 0755 /usr/local/bin;
    
EXPOSE 80 443 8080 8443
    
#Changes need root, switch back to jetbrains in entrypoint
USER root

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
