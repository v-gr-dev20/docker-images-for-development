# Основным инструментом для сборки Android-проектов является Gradle 
FROM gradle:latest

# Задаем переменные с локальной папкой для Android SDK и 
# версиями платформы и инструментария
ENV SDK_URL="https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip" \
	ANDROID_HOME="/usr/local/android-sdk" \
	ANDROID_VERSION=30 \
	ANDROID_BUILD_TOOLS_VERSION=30.0.3

# Создаем папку, скачиваем туда SDK и распаковываем архив,
# который после сборки удаляем
RUN mkdir "$ANDROID_HOME" .android \
	&& cd "$ANDROID_HOME" \
	&& curl -o sdk.zip $SDK_URL \
	&& unzip sdk.zip \
	&& rm sdk.zip

# Запускаем обновление SDK и установку build-tools, platform-tools
RUN yes | $ANDROID_HOME/tools/bin/sdkmanager --licenses \
 && $ANDROID_HOME/tools/bin/sdkmanager --update \
 && $ANDROID_HOME/tools/bin/sdkmanager "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" \
	"platforms;android-${ANDROID_VERSION}" \
	"platform-tools" \
	"tools" \
 && $ANDROID_HOME/tools/bin/sdkmanager --update