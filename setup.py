#! /usr/bin/env python

from setuptools import find_packages, setup

setup(
    name="gasync",
    version="0.0.3",
    install_requires=['hy>=0.15'],
    packages=find_packages(exclude=['tests']),
    package_data={
        'gasync': ['*.hy'],
    },
    test_suite='nose.collector',
    tests_require=['nose'],
    author="Hirotaka Niitsuma",
    author_email="hirotaka.niitsuma@gmail.com",
    long_description="""generic async func in Hy.""",
    license="GNU Affero General Public License",
    url="https://github.com/niitsuma/gasync",
    platforms=['any'],
    python_requires='>=3.6',
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Intended Audience :: Developers",
        "Operating System :: OS Independent",
        "Programming Language :: Lisp",
        "Topic :: Software Development :: Libraries",
    ]
)
