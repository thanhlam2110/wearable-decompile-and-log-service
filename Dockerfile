# Use Ubuntu 22.04 as the base image
FROM ubuntu:22.04

# Set non-interactive mode
ENV DEBIAN_FRONTEND=noninteractive

# Update and install dependencies including wget, unzip, rsync, git
RUN apt-get update && apt-get install -y \
    openjdk-11-jre \
    openjdk-11-jdk \
    python3 \
    git \
    wget \
    zip \
    unzip \
    rsync \
    gnupg \
    net-tools \
    nano \
    iputils-ping \
    telnet \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3 as default
RUN python3 -m pip install kafka-python
RUN ln -s /usr/bin/python3 /usr/bin/python

# Create necessary directories
RUN mkdir -p /root/decompile/apk
RUN mkdir -p /root/decompile/java
RUN mkdir -p /var/log/decompile
RUN mkdir -p /var/log/decompile/apk-done
RUN mkdir -p /var/log/decompile/apk-time-out

# Copy procyon-decompiler-0.6.0.jar from host to container
COPY procyon-decompiler-0.6.0.jar /root/apk-tool/procyon-decompiler-0.6.0.jar
# Copy send_to_kafka.py script to the container
COPY send_to_kafka.py /root/send_to_kafka.py

# Set execute permissions for the Python script
RUN chmod +x /root/send_to_kafka.py
# Clone dex2jar from GitHub and build
WORKDIR /root/apk-tool
RUN git clone https://github.com/pxb1988/dex2jar.git
WORKDIR /root/apk-tool/dex2jar
RUN ./gradlew distZip
WORKDIR /root/apk-tool/dex2jar/dex-tools/build/distributions/
RUN unzip dex-tools-2.x.zip
WORKDIR /root/apk-tool/dex2jar/dex-tools-2.x/
RUN chmod -R 777 /root/apk-tool/*

# Set working directory
RUN touch /root/decompile/decompile-apk.log
RUN chmod -R 777 /root/decompile/*
WORKDIR /root/decompile

# Run a script to continuously check for APK files and perform conversion with dynamic timeout
CMD ["/bin/bash", "-c", "\
    while true; do \
        for file in /root/decompile/apk/*.apk; do \
            if [ -f \"$file\" ] && [ -s \"$file\" ]; then \
                filename=$(basename \"$file\" .apk); \
                row=$(grep \"$filename\" /root/decompile/decompile.csv); \
                apk_name=$(echo \"$row\" | awk -F',' '{print $1}'); \
                decompile_jar=$(echo \"$row\" | awk -F',' '{print $2}'); \
                decompile_java=$(echo \"$row\" | awk -F',' '{print $3}'); \
                file_size=$(stat -c%s \"$file\"); \
                timeout_value=3600; \
                if [ $file_size -lt 20000000 ]; then \
                    timeout_value=3600; \
                elif [ $file_size -ge 20000000 ] && [ $file_size -lt 50000000 ]; then \
                    timeout_value=5400; \
                elif [ $file_size -ge 50000000 ] && [ $file_size -lt 100000000 ]; then \
                    timeout_value=7200; \
                elif [ $file_size -ge 100000000 ] && [ $file_size -lt 150000000 ]; then \
                    timeout_value=10800; \
                elif [ $file_size -ge 150000000 ] && [ $file_size -lt 200000000 ]; then \
                    timeout_value=14400; \
                elif [ $file_size -ge 200000000 ] && [ $file_size -lt 300000000 ]; then \
                    timeout_value=18000; \
                else \
                    timeout_value=21600; \
                fi; \
                if [ -z \"$decompile_jar\" ]; then \
                    python /root/send_to_kafka.py '193.206.183.26:29093' 'decompile-log' \"Start convert APK to JAR file $filename\" && \
                    sh /root/apk-tool/dex2jar/dex-tools/build/distributions/dex-tools-2.x/d2j-dex2jar.sh \"$file\" -o \"/root/decompile/java/${filename}.jar\" 2>&1 | tee -a /root/decompile/decompile-apk.log && \
                    sleep 120 && \
                    python /root/send_to_kafka.py '193.206.183.26:29093' 'decompile-log' \"Start decompile file $filename with timeout value $timeout_value and file size $file_size\" && \
                    timeout $timeout_value java -jar /root/apk-tool/procyon-decompiler-0.6.0.jar \"/root/decompile/java/${filename}.jar\" -o \"/root/decompile/java/${filename}-java\" 2>&1 | tee -a /root/decompile/decompile-apk.log; \
                    java_exit_code=${PIPESTATUS[0]}; \
                    if [ $java_exit_code -eq 124 ]; then \
                        sed -i \"s/$apk_name,,/$apk_name,DONE,/\" /root/decompile/decompile.csv && \
                        sed -i \"s/$apk_name,DONE,/$apk_name,TIMEOUT,TIMEOUT/\" /root/decompile/decompile.csv && \
                        rm -f \"/root/decompile/java/${filename}.jar\" && \
                        echo \"Timeout decompile $filename\" >> /root/decompile/decompile-apk.log && \
                        echo \"Timeout decompile $filename\" >> /root/decompile/java/decompile.log && \
                        python /root/send_to_kafka.py '193.206.183.26:29093' 'decompile-log' \"Timeout decompile $filename\"; \
                        mv \"$file\" /root/decompile/apk-time-out/; \
                    else \
                        sed -i \"s/$apk_name,,/$apk_name,DONE,/\" /root/decompile/decompile.csv && \
                        sed -i \"s/$apk_name,DONE,/$apk_name,DONE,DONE/\" /root/decompile/decompile.csv && \
                        rm -f \"/root/decompile/java/${filename}.jar\" && \
                        echo \"Finish decompile $filename\" >> /root/decompile/decompile-apk.log && \
                        echo \"Finish decompile $filename\" >> /root/decompile/java/decompile.log && \
                        python /root/send_to_kafka.py '193.206.183.26:29093' 'decompile-log' \"Finish decompile $filename\"; \
                        zip -r /root/decompile/java/${filename}-java.zip /root/decompile/java/${filename}-java; \
                        python /root/send_to_kafka.py '193.206.183.26:29093' 'decompile-log' \"ZIP directory $filename\"; \
                        mv \"$file\" /root/decompile/apk-done/; \
                    fi; \
                else \
                    rm -f \"/root/decompile/java/${filename}.jar\" && \
                    echo \"Already exists decompile of $filename\" >> /root/decompile/decompile-apk.log && \
                    echo \"Already exists decompile of $filename\" >> /root/decompile/java/decompile.log && \
                    python /root/send_to_kafka.py '193.206.183.26:29093' 'decompile-log' \"Already exists decompile $filename\"; \
                fi; \
            fi; \
        done; \
        sleep 10; \
    done"]

