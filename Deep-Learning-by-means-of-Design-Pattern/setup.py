# -*- coding: utf-8 -*-
from setuptools import setup, find_packages
from setuptools import Extension
import numpy as np
import os
from Cython.Distutils import build_ext
from Cython.Build import cythonize


pyx_list = []
for dirpath, dirs, files in os.walk('.'):
    for f in files:
        if ".pyx" in f and "checkpoint" not in f:
            pyx_path = os.path.join(dirpath, f)
            pyx_list.append(Extension("*", [pyx_path]))


def read_readme(file_name):
    from os import path
    this_directory = path.abspath(path.dirname(__file__))
    with open(path.join(this_directory, file_name), encoding='utf-8') as f:
        long_description = f.read()

    return long_description


setup(
    name='pydbm',
    version='1.3.5',
    description='`pydbm` is Python library for building Restricted Boltzmann Machine(RBM), Deep Boltzmann Machine(DBM), Recurrent neural network Restricted Boltzmann Machine(RNN-RBM), LSTM Recurrent Temporal Restricted Boltzmann Machine(LSTM-RTRBM), and Shape Boltzmann Machine(Shape-BM).',
    long_description=read_readme("README.md"),
    long_description_content_type='text/markdown',
    url='https://github.com/chimera0/accel-brain-code/tree/master/Deep-Learning-by-means-of-Design-Pattern',
    author='chimera0',
    author_email='ai-brain-lab@accel-brain.com',
    license='GPL2',
    classifiers=[
        'Development Status :: 5 - Production/Stable',
        'Intended Audience :: Information Technology',
        'Intended Audience :: Science/Research',
        'Topic :: Text Processing',
        'Topic :: Scientific/Engineering :: Artificial Intelligence',
        'License :: OSI Approved :: GNU General Public License v2 (GPLv2)',
        'Programming Language :: Python :: 3',
    ],
    keywords='restricted boltzmann machine autoencoder auto-encoder rnn rbm rtrbm',
    install_requires=['numpy', 'cython'],
    include_dirs=[ '.', np.get_include()],
    cmdclass={'build_ext': build_ext},
    ext_modules=cythonize(pyx_list, include_path=[np.get_include()])
)
