FROM mcr.microsoft.com/dotnet/sdk:8.0-jammy

# ARG OSSL_INSTALL_DIR="/usr/local/ssl"

RUN apt-get -y update && \
    apt-get -y install gcc build-essential git wget curl vim && \
    apt-get -y remove openssl

# ---- OpenSSL FIPS ----
WORKDIR /apps
COPY ./openssl-3.0.8.tar.gz /apps/ossl.tar.gz
RUN tar -xzvf ossl.tar.gz
RUN cd openssl-3.0.8/ && \
    ./Configure enable-fips \
    '-Wl,-rpath,$(LIBRPATH)' && \
    make install

COPY ./openssl.cnf /usr/local/ssl/openssl.header.cnf
RUN mv /usr/local/ssl/openssl.cnf /usr/local/ssl/openssl.body.cnf && \
    mv /usr/local/ssl/openssl.header.cnf /usr/local/ssl/openssl.cnf 
    # && \
    # cat /usr/local/ssl/openssl.body.cnf >> /usr/local/ssl/openssl.cnf

# RUN cd openssl-3.0.8/ && \
#     ./Configure enable-fips --prefix=${OSSL_INSTALL_DIR} \
#     --openssldir=${OSSL_INSTALL_DIR} \
#     '-Wl,-rpath,${OSSL_INSTALL_DIR}/lib' && \
#     make install

# RUN openssl fipsinstall -out /usr/local/ssl/fipsmodule.cnf -module /usr/local/lib/ossl-modules/fips.so
# ----------------------

# ---- Build and Run .NET App ----
WORKDIR /app
COPY "./WebApplication1" .
RUN rm -rf ./bin && rm -rf ./obj

RUN dotnet publish ./WebApplication1.csproj -o /app/publish

WORKDIR /app/publish
ENTRYPOINT [ "dotnet", "WebApplication1.dll" ]
# --------------------------------

# RUN apt-get update && apt-get install gcc build-essential git wget curl vim -y

# WORKDIR /apps
# # https://github.com/openssl/openssl/blob/master/README-FIPS.md
# RUN wget https://www.openssl.org/source/openssl-3.0.0.tar.gz && tar -xzvf openssl-3.0.0.tar.gz

# RUN cd openssl-3.0.0 && ./config enable-fips enable-ssl-trace && make && make install
# ENV LD_LIBRARY_PATH /usr/local/lib/:/usr/local/lib64/
# RUN openssl fipsinstall -out /usr/local/ssl/fipsmodule.cnf -module /usr/local/lib64/ossl-modules/fips.so

# RUN rm /usr/local/ssl/openssl.cnf
# RUN echo 'openssl_conf = openssl_init\n\
# \n\
# .include /usr/local/ssl/fipsmodule.cnf\n\
# \n\
# [openssl_init]\n\
# providers = provider_sect\n\
# alg_section = algorithm_sect\n\
# \n\
# [provider_sect]\n\
# fips = fips_sect\n\
# base = base_sect\n\
# \n\
# [base_sect]\n\
# activate = 1\n\
# \n\
# [algorithm_sect]\n\
# default_properties = fips=yes\n\
# ' > /usr/local/ssl/openssl.cnf