# SPDX-FileCopyrightText: © 2025 Nfrastack <code@nfrastack.com>
#
# SPDX-License-Identifier: MIT

ARG \
    BASE_IMAGE

FROM ${BASE_IMAGE}

LABEL \
        org.opencontainers.image.title="Fusiondirectory" \
        org.opencontainers.image.description="Containerized directory administrator" \
        org.opencontainers.image.url="https://hub.docker.com/r/nfrastack/fusiondirectory" \
        org.opencontainers.image.documentation="https://github.com/nfrastack/container-fusiondirectory/blob/main/README.md" \
        org.opencontainers.image.source="https://github.com/nfrastack/container-fusiondirectory.git" \
        org.opencontainers.image.authors="Nfrastack <code@nfrastack.com>" \
        org.opencontainers.image.vendor="Nfrastack <https://www.nfrastack.com>" \
        org.opencontainers.image.licenses="MIT"

ARG \
    ARGONAUT_REPO_URL="https://gitlab.fusiondirectory.org/fusiondirectory/argonaut" \
    ARGONAUT_VERSION="argonaut-1.4" \
    FUSIONDIRECTORY_INTEGRATOR_REPO_URL="https://github.com/fusiondirectory/fusiondirectory-integrator" \
    FUSIONDIRECTORY_INTEGRATOR_VERSION="1.2" \
    FUSIONDIRECTORY_ORCHESTRATOR_REPO_URL="https://github.com/fusiondirectory/fusiondirectory-orchestrator" \
    FUSIONDIRECTORY_ORCHESTRATOR_VERSION="1.1" \
    FUSIONDIRECTORY_VERSION="fusiondirectory-1.5" \
    FUSIONDIRECTORY_REPO_URL="https://github.com/fusiondirectory/fusiondirectory" \
    FUSIONDIRECTORY_TOOLS_VERSION="1.2" \
    FUSIONDIRECTORY_TOOLS_REPO_URL="https://github.com/fusiondirectory/fusiondirectory-tools" \
    FUSIONDIRECTORY_PLUGINS_VERSION="fusiondirectory-1.5" \
    FUSIONDIRECTORY_PLUGINS_REPO_URL="https://github.com/fusiondirectory/fusiondirectory-plugins" \
    SCHEMA2LDIF_REPO_URL="https://github.com/fusiondirectory/schema2ldif" \
    SCHEMA2LDIF_VERSION="1.3" \
    SCRIPTACULOUS_REPO_URL="https://github.com/madrobby/scriptaculous" \
    SCRIPTACULOUS_VERSION="v1.9.0" \
    SMARTY_VERSION="v3.1.48" \
    SMARTY_REPO_URL="https://github.com/smarty-php/smarty" \
    SMARTY_GETTEXT_VERSION="1.7.0" \
    SMARTY_GETTEXT_REPO_URL="https://github.com/smarty-gettext/smarty-gettext"

COPY CHANGELOG.md /usr/src/container/CHANGELOG.md
COPY LICENSE /usr/src/container/LICENSE
COPY README.md /usr/src/container/README.md

ENV \
    CONTAINER_ENABLE_SCHEDULING=TRUE \
    NGINX_SITE_ENABLED=fusiondirectory \
    NGINX_WEBROOT=/www/fusiondirectory \
    PHP_ENABLE_CREATE_SAMPLE_PHP=FALSE \
    PHP_MODULE_ENABLE=GD=TRUE \
    PHP_MODULE_ENABLE_GETTEXT=TRUE \
    PHP_MODULE_ENABLE_ICONV=TRUE \
    PHP_MODULE_ENABLE_IMAGICK=TRUE \
    PHP_MODULE_ENABLE_IMAP=TRUE \
    PHP_MODULE_ENABLE_JSON=TRUE \
    PHP_MODULE_ENABLE_LDAP=TRUE \
    PHP_MODULE_ENABLE_OPENSSL=TRUE \
    PHP_MODULE_ENABLE_POSIX=TRUE \
    PHP_MODULE_ENABLE_SESSION=TRUE \
    PHP_MODULE_ENABLE_SIMPLEXML=TRUE \
    PHP_MODULE_ENABLE_XML=TRUE \
    PHP_MODULE_ENABLE_YAML=TRUE \
    IMAGE_NAME="nfrastack/fusiondirectory" \
    IMAGE_REPO_URL="https://github.com/nfrastack/container-fusiondirectory/"

RUN echo "" && \
    ARGONAUT_BUILD_DEPS_ALPINE=" \
                                    coreutils \
                                    build-base \
                                    git \
                                    make \
                                    perl-dev \
                               " \
                               && \
    ARGONAUT_RUN_DEPS_ALPINE=" \
                                perl-config-inifiles \
                                perl-datetime \
                                perl-ldap \
                                perl-mime-base64 \
                                perl-crypt-cbc \
                                perl-file-copy-recursive \
                                perl-io-socket-ssl \
                                perl-io-tty \
                                perl-json \
                                perl-mail-sendmail \
                                perl-mime-tools \
                                perl-module-pluggable \
                                perl-net-ldap \
                                perl-path-class \
                                perl-term-readkey \
                                perl-xml-twig \
                             " \
                             && \
    FUSIONDIRECTORY_BUILD_DEPS_ALPINE=" \
                                        git \
                                      " \
                                      && \
    FUSIONDIRECTORY_RUN_DEPS_ALPINE=" \
                                        gettext \
                                        gettext-lang \
                                        openldap-clients \
                                        rsyslog \
                                    " \
                                    && \
    \
    source /container/base/functions/container/build && \
    container_build_log image && \
    package update && \
    package upgrade && \
    package install \
                        ARGONAUT_BUILD_DEPS \
                        ARGONAUT_RUN_DEPS \
                        FUSIONDIRECTORY_BUILD_DEPS \
                        FUSIONDIRECTORY_RUN_DEPS \
                        && \
    php-ext prepare && \
    php-ext reset && \
    php-ext enable core && \
    \
    clone_git_repo "${ARGONAUT_REPO_URL}" "${ARGONAUT_VERSION}" /usr/src/argonaut && \
    ln -s /usr/bin/perl /usr/local/bin/perl && \
    curl -sSL http://cpanmin.us -o /usr/bin/cpanm && \
    chmod +x /usr/bin/cpanm && \
    cpanm -n \
                App::Daemon \
                Archive::Extract \
                Bytes::Random::Secure \
                HTTP::Daemon \
                JSON::Any \
                JSON::RPC \
                Log::Handler \
                POE \
                POE::Component::Server::JSONRPC::Http \
                POE::Component::Schedule \
                POE::Component::Server::SimpleHTTP \
                POE::Component::Pool::Thread \
                POE::Component::SSLify \
                XML::SAX::Expat \
                && \
    cp -R /usr/local/share/perl5/site_perl/* /usr/share/perl5/vendor_perl/ && \
    mkdir -p \
                /etc/argonaut \
                /var/log/argonaut \
                && \
    chmod +x /usr/src/argonaut/*/bin/* && \
    cp -R /usr/src/argonaut/argonaut-common/{Argonaut,XML} /usr/share/perl5/vendor_perl/ && \
    cp -R /usr/src/argonaut/argonaut-common/argonaut.conf /etc/argonaut && \
    cp -R /usr/src/argonaut/argonaut-fusiondirectory/bin/* /usr/local/bin && \
    cp -R /usr/src/argonaut/argonaut-fusioninventory/bin/* /usr/local/bin && \
    cp -R /usr/src/argonaut/argonaut-server/bin/argonaut-server /usr/local/bin && \
    cp -R /usr/src/argonaut/argonaut-server/Argonaut /usr/share/perl5/vendor_perl/ && \
    cp -R /usr/src/argonaut/*/Argonaut/ /usr/share/perl5/vendor_perl/ && \
    container_build_log add "Argonaut" "${ARGONAUT_VERSION#argonaut-}" "${ARGONAUT_REPO_URL}" && \
    mkdir -p /container/data/fusiondirectory && \
    clone_git_repo "${FUSIONDIRECTORY_REPO_URL}" "${FUSIONDIRECTORY_VERSION}" /usr/src/fusiondirectory && \
    container_build_log add "FusionDirectory" "${FUSIONDIRECTORY_VERSION#fusiondirectory-}" "${FUSIONDIRECTORY_REPO_URL}" && \
    clone_git_repo "${FUSIONDIRECTORY_PLUGINS_REPO_URL}" "${FUSIONDIRECTORY_PLUGINS_VERSION}" /container/data/fusiondirectory/plugins && \
    container_build_log add "FusionDirectory Plugins" "${FUSIONDIRECTORY_PLUGINS_VERSION#fusiondirectory-}" "${FUSIONDIRECTORY_PLUGINS_REPO_URL}" && \
    rm -rf "${GIT_REPO_SRC_FUSIONDIRECTORY_PLUGINS%/}"/.git && \
    clone_git_repo https://github.com/tiredofit/fusiondirectory-plugin-kopano main /usr/src/fusiondirectory-plugin-kopano && \
    cp -R "${GIT_REPO_SRC_FUSIONDIRECTORY_PLUGIN_KOPANO%/}"/kopano /container/data/fusiondirectory/plugins/ && \
    container_build_log add "FusionDirectory Kopano Plugin" "main" "https://github.com/tiredofit/fusiondirectory-plugin-kopano" && \
    clone_git_repo https://github.com/slangdaddy/fusiondirectory-plugin-nextcloud master /usr/src/fusiondirectory-plugin-nextcloud && \
    rm -rf \
           "${GIT_REPO_SRC_FUSIONDIRECTORY_PLUGIN_NEXTCLOUD%/}"/.git \
           "${GIT_REPO_SRC_FUSIONDIRECTORY_PLUGIN_NEXTCLOUD%/}"/src/DEBIAN && \
    mkdir -p /container/data/fusiondirectory/plugins/nextcloud && \
    cp -R /usr/src/fusiondirectory-plugin-nextcloud/src/* /container/data/fusiondirectory/plugins/nextcloud/ && \
    container_build_log add "FusionDirectory Nextcloud Plugin Schema" "master" "https://github.com/slangdaddy/fusiondirectory-plugin-nextcloud" && \
    clone_git_repo https://github.com/gallak/fusiondirectory-plugins-seafile master /usr/src/fusiondirectory-plugins-seafile && \
    rm -rf \
            "${GIT_REPO_SRC_FUSIONDIRECTORY_PLUGINS_SEAFILE%/}"/.git \
            "${GIT_REPO_SRC_FUSIONDIRECTORY_PLUGINS_SEAFILE%/}"/README.md && \
    mkdir -p /container/data/fusiondirectory/plugins/seafile && \
    cp -R /usr/src/fusiondirectory-plugins-seafile/* /container/data/fusiondirectory/plugins/seafile/ && \
    container_build_log add "FusionDirectory Seafile Plugin Schema" "main" "https://github.com/gallak/fusiondirectory-plugins-seafile" && \
    clone_git_repo "${FUSIONDIRECTORY_INTEGRATOR_REPO_URL}" "${FUSIONDIRECTORY_INTEGRATOR_VERSION}" && \
    mkdir -p /usr/share/php/FusionDirectory/ && \
    cp -R "${GIT_REPO_SRC_FUSIONDIRECTORY_INTEGRATOR%/}"/src/* /usr/share/php/FusionDirectory && \
    container_build_log add "FusionDirectory Integrator" "${FUSIONDIRECTORY_INTEGRATOR_VERSION}" "${FUSIONDIRECTORY_INTEGRATOR_REPO_URL}"&& \
    clone_git_repo "${FUSIONDIRECTORY_TOOLS_REPO_URL}" "${FUSIONDIRECTORY_TOOLS_VERSION}" && \
    cp -aR "${GIT_REPO_SRC_FUSIONDIRECTORY_TOOLS%/}"/bin/* /usr/local/bin && \
    cp -aR "${GIT_REPO_SRC_FUSIONDIRECTORY_TOOLS%/}"/src/FusionDirectory/Tools /usr/share/php/FusionDirectory/FusionDirectory/ && \
    container_build_log add "FusionDirectory Tools" "${FUSIONDIRECTORY_TOOLS_VERSION}" "${FUSIONDIRECTORY_TOOLS_REPO_URL}" && \
    clone_git_repo "${FUSIONDIRECTORY_ORCHESTRATOR_REPO_URL}" "${FUSIONDIRECTORY_ORCHESTRATOR_VERSION}" /usr/share/fusiondirectory-orchestrator && \
    rm -rf "${GIT_REPO_SRC_FUSIONDIRECTORY_ORCHESTRATOR%/}"/.git && \
    mkdir -p /container/data/fusiondirectory/orchestrator && \
    cp -R "${GIT_REPO_SRC_FUSIONDIRECTORY_ORCHESTRATOR%/}"/contrib/orchestrator.conf /container/data/fusiondirectory/orchestrator && \
    container_build_log add "FusionDirectory Orchestrator" "${FUSIONDIRECTORY_ORCHESTRATOR_VERSION}" "${FUSIONDIRECTORY_ORCHESTRATOR_REPO_URL}" && \
    clone_git_repo "${SCHEMA2LDIF_REPO_URL}" "${SCHEMA2LDIF_VERSION}" && \
    cp -aR "${GIT_REPO_SRC_SCHEMA2LDIF%/}"/bin/* /usr/local/bin/ && \
    container_build_log add "Schema2LDIF" "${SCHEMA2LDIF_VERSION}" "${SCHEMA2LDIF_REPO_URL}" && \
    clone_git_repo "${SCRIPTACULOUS_REPO_URL}" "${SCRIPTACULOUS_VERSION}" && \
    cp -R "${GIT_REPO_SRC_SCRIPTACULOUS%/}"/lib/prototype.js /usr/src/fusiondirectory/html/include && \
    cp -R "${GIT_REPO_SRC_SCRIPTACULOUS%/}"/src/{scriptaculous.js,builder.js,controls.js,dragdrop.js,effects.js,slider.js,sound.js} /usr/src/fusiondirectory/html/include && \
    container_build_log add "Scriptaculous" "${SCRIPTACULOUS_VERSION}" "${SCRIPTACULOUS_REPO_URL}" && \
    clone_git_repo "${SMARTY_REPO_URL}" "${SMARTY_VERSION}" && \
    mkdir -p /usr/share/php/smarty3/plugins && \
    cp -r ${GIT_REPO_SRC_SMARTY%/}/libs/* /usr/share/php/smarty3 && \
    ln -s /usr/share/php/smarty3/Smarty.class.php /usr/share/php/smarty3/smarty.class.php && \
    container_build_log add "Smarty" "${SMARTY_VERSION}" "${SMARTY_REPO_URL}" && \
    clone_git_repo "${SMARTY_GETTEXT_REPO_URL}" "${SMARTY_GETTEXT_VERSION}" && \
    cp -R "${GIT_REPO_SRC_SMARTY_GETTEXT%/}"/block.t.php /usr/share/php/smarty3/plugins/ && \
    cp -R "${GIT_REPO_SRC_SMARTY_GETTEXT%/}"/tsmarty2c.php /usr/local/bin && \
    chmod 750 /usr/local/bin/tsmarty2c.php && \
    container_build_log add "Smarty Gettext" "${SMARTY_GETTEXT_VERSION}" "${SMARTY_GETTEXT_REPO_URL}" && \
    cp -aR "${GIT_REPO_SRC_FUSIONDIRECTORY%/}"/contrib/smarty/plugins/* /usr/share/php/smarty3/plugins/ && \
    mkdir -p \
                /var/cache/fusiondirectory/{fai,include,locale,template,tmp} \
                /etc/fusiondirectory && \
    cp -R "${GIT_REPO_SRC_FUSIONDIRECTORY%/}"/contrib/fusiondirectory.conf /var/cache/fusiondirectory/template/fusiondirectory.conf && \
    cp -R "${GIT_REPO_SRC_FUSIONDIRECTORY%/}"/contrib /container/data/fusiondirectory/ && \
    \
    mkdir -p ${NGINX_WEBROOT} && \
    cp -R /usr/src/fusiondirectory/* "${NGINX_WEBROOT}" && \
    fusiondirectory-configuration-manager --set-var fd_home="${NGINX_WEBROOT}" --write-vars --yes && \
    touch /etc/debian_version && \
    yes Yes | fusiondirectory-configuration-manager --set-var fd_home="${NGINX_WEBROOT}" --check-directories --update-cache && \
    fusiondirectory-configuration-manager --set-var fd_home="${NGINX_WEBROOT}" --update-locales --update-cache --yes && \
    \
    package remove \
                    ARGONAUT_BUILD_DEPS \
                    FUSIONDIRECTORY_BUILD_DEPS \
                    && \
    package cleanup

COPY rootfs /
