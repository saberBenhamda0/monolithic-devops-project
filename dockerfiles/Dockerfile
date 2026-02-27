FROM eclipse-temurin:17-jdk-alpine

WORKDIR /app

COPY target/*.jar app.jar

# create a read only user 
RUN groupadd -r read-group && useradd -r -g read-group read-user

# restrict switching to root user for security purposes
# we change the shell for root to nologin 
RUN chsh -s /usr/sbin/nologin root 

EXPOSE 9632

ENTRYPOINT ["java", "-jar", "app.jar"]
