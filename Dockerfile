FROM ubuntu:22.04

# نثبت المتطلبات الأساسية
RUN apt-get update && apt-get install -y curl git sudo

WORKDIR /app
COPY . .

# نعطي صلاحية ونشغل السكربت وقت البناء
RUN chmod +x deploy.sh
RUN bash deploy.sh || true

# بعد ما السكربت يخلص، نشغل التطبيق
EXPOSE 443
CMD ["bash", "-c", "tail -f /dev/null"]
