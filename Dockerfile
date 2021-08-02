FROM openpose:2
COPY dirt /dirt
RUN pip install tensorflow==2.1.0
RUN cd /dirt && \
    pip install -e .