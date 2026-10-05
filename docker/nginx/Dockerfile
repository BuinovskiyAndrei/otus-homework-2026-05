FROM nginx:latest

RUN rm -f /etc/nginx/conf.d/default.conf

COPY ./nginx.conf /etc/nginx/conf.d/default.conf

WORKDIR /var/www/public

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
