FROM registry.socram.net/socrambanque/maven:3.5.0-jdk-8-alpine as builder

WORKDIR /app
ADD . /app

RUN mvn -B -U -DskipTests clean deploy

FROM registry.socram.net/openjdk:8-jdk-alpine 

ARG ARTIFACT_ID
ARG ARTIFACT_VERSION
ARG ARTIFACT_PACKAGING
ENV JAVA_OPTS=""
ENV ENVIRONMENT_WEBAPP="default"
ENV LIVRET_DIGITAL_SPRING_CLOUD_CONFIG_SERVER_URL=""
ENV PRODUIT_CREDIT_DATABASE_JDBC_URL=""
ENV PRODUIT_CREDIT_DATABASE_JDBC_USERNAME=""
ENV PRODUIT_CREDIT_DATABASE_JDBC_PASSWORD=""
ENV PRODUIT_CREDIT_DATABASE_JDBC_DRIVER_CLASS_NAME=""
ENV PATH_PRODUIT_CREDIT_SERVICE="/"

# modification du timezone pour avoir l'heure correcte du host
RUN mkdir -p /app/logs;\
    echo "Europe/Paris" > /etc/timezone


VOLUME /app/logs
COPY --from=builder /app/target/${ARTIFACT_ID}-${ARTIFACT_VERSION}.${ARTIFACT_PACKAGING} /app.${ARTIFACT_PACKAGING}

EXPOSE 8080

ENTRYPOINT exec java $JAVA_OPTS -jar -Dspring.profiles.active=${ENVIRONMENT_WEBAPP} app.war
