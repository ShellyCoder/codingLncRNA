from setuptools import setup, find_packages

setup(
    name="codingLncRNA",
    version="0.1",
    packages=find_packages(),
    package_data={"codingLncRNA": ["data/*.csv"]},
    install_requires=[
        "pandas",
    ],
)