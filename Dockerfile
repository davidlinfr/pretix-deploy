FROM pretix/standalone:stable

USER root

RUN pip3 install --no-cache-dir \
    pretix-mollie \
    pretix-oidc

USER pretixuser
