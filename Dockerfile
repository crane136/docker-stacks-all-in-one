FROM continuumio/miniconda3:4.9.2
ENV USER hai
ENV GROUP hai
ENV HOME /home/hai
USER root

RUN addgroup --gid 1001 $GROUP \
  && adduser --home $HOME --uid 1005 $USER --gid 1001 \
  && mkdir -p $HOME/workspace \
  && chown -R $USER:$GROUP $HOME/workspace

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV SHELL /bin/bash

# config the images source
RUN mkdir ~/.pip && chmod 775 -R ~/.pip \
&& touch ~/.pip/pip.conf \
&& echo "[global]">>~/.pip/pip.conf \
#&& echo "index-url=https://pypi.tuna.tsinghua.edu.cn/simple">>~/.pip/pip.conf \
#&& echo "trusted-host=pypi.tuna.tsinghua.edu.cn">>~/.pip/pip.conf \
&& echo "index-url=http://mirrors.myhuaweicloud.com/pypi/web/simple">>~/.pip/pip.conf \
&& echo "trusted-host=mirrors.myhuaweicloud.com">>~/.pip/pip.conf \
&& echo "timeout=6000">>~/.pip/pip.conf \
&& pip install --upgrade pip \
&& pip install --upgrade --force-reinstall --no-cache-dir jupyterlab ipykernel \
&& jupyter notebook --generate-config \
&& chown -R $USER:$GROUP $HOME/.jupyter \
#&& echo "c.NotebookApp.tornado_settings={"headers" :{"Content-Security-Policy" :"frame-ancestors self '*' "}}">>/home/hai/.jupyter/jupyter_notebook_config.py \
&& echo "c.NotebookApp.allow_origin='*'">>/home/hai/.jupyter/jupyter_notebook_config.py \
&& echo "c.NotebookApp.open_browser=False">>/home/hai/.jupyter/jupyter_notebook_config.py \
&& echo "c.NotebookApp.base_url='/home/hai/workspace'">>/home/hai/.jupyter/jupyter_notebook_config.py \
&& sed -i 's/display_name": "Python 3/display_name": "Python 3.8.5/g' /opt/conda/share/jupyter/kernels/python3/kernel.json
# conda images source
RUN conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/ \
&& conda config --set show_channel_urls yes

# Create the Python virtual environment
# 1) py2.7.18
RUN conda create -n python2.7 python=2.7.18 \
&& . /opt/conda/etc/profile.d/conda.sh \
&& conda activate python2.7 \
&& pip install --upgrade pip \
&& conda install ipykernel jupyterlab \
&& python -m ipykernel install --user --name python2.7 \
&& conda deactivate

# Create the TensorFlow virtual environment
# 1) tensorflow2.4.0-py3.7.3
COPY tf2.4.0-requirements.txt $HOME/workspace
RUN conda create -n tensorflow2.4.0-py3.7.3 python=3.7.3 \
&& . /opt/conda/etc/profile.d/conda.sh \
&& conda activate tensorflow2.4.0-py3.7.3 \
&& pip install --upgrade pip \
&& pip install -r tf2.4.0-requirements.txt \
&& python -m ipykernel install --user --name tensorflow2.4.0-py3.7.3 \
&& conda deactivate

# 2) tensorflow1.15-py3.6.5
COPY tf1.15-requirements.txt $HOME/workspace
RUN conda create -n tensorflow1.15-py3.6.5 python=3.6.5 \
&& . /opt/conda/etc/profile.d/conda.sh \
&& conda activate tensorflow1.15-py3.6.5 \
&& pip install --upgrade pip \
&& pip install -r tf1.15-requirements.txt \
&& python -m ipykernel install --user --name tensorflow1.15-py3.6.5 \
&& conda deactivate

# Create the Pytorch virtual environment
# 1) pytorch1.7.0-py3.7.3
COPY pytorch1.7.0-requirements.txt $HOME/workspace
RUN conda create -n pytorch1.7.0-py3.7.3 python=3.7.3 \
&& . /opt/conda/etc/profile.d/conda.sh \
&& conda activate pytorch1.7.0-py3.7.3 \
&& pip install --upgrade pip \
&& pip install -r pytorch1.7.0-requirements.txt \
&& python -m ipykernel install --user --name pytorch1.7.0-py3.7.3 \
&& conda deactivate

# 2) pytorch1.5.0-py3.6.5
COPY pytorch1.5.0-requirements.txt $HOME/workspace
RUN conda create -n pytorch1.5.0-py3.6.5 python=3.6.5 \
&& . /opt/conda/etc/profile.d/conda.sh \
&& conda activate pytorch1.5.0-py3.6.5 \
&& pip install --upgrade pip \
&& pip install -r pytorch1.5.0-requirements.txt \
&& python -m ipykernel install --user --name pytorch1.5.0-py3.6.5 \
&& conda deactivate

RUN chown -R $USER:$GROUP ~/.local
WORKDIR $HOME/workspace
USER $USER
