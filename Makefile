SHELL := bash
ROOT := $(shell pwd -P)

export GRAALVM_HOME ?= /tmp/graalvm

LIB_PATH := libsci/target

LIBSCI_SO := $(LIB_PATH)/libsci.so
LIBSCI_JAVA := libsci/src/sci/impl/LibSci.java
LIBSCI_CLASS := libsci/src/sci/impl/LibSci.class

SCI_JAR := target/sci-0.8.40-standalone.jar
SVM_JAR := $(GRAALVM_HOME)/lib/svm/builder/svm.jar

export PATH := $(GRAALVM_HOME)/bin:$(PATH)
export LD_LIBRARY_PATH := $(LIB_PATH)

#------------------------------------------------------------------------------
default:

test: test.py $(LIBSCI_SO)
	python3 $< <<<'(inc 41)'

clean:
	$(RM) -r target/ .cpcache/ $(LIB_PATH)
	$(RM) libsci/src/sci/impl/LibSci.class

$(LIBSCI_SO): $(LIBSCI_CLASS)
	mkdir -p $(dir $@)
	native-image \
	    --shared \
	    --initialize-at-build-time \
	    --verbose \
	    --no-fallback \
	    --no-server \
	    --enable-preview \
	    -jar target/sci-0.8.40-standalone.jar \
	    -cp libsci/src \
	    -H:+ReportExceptionStackTraces \
	    -J-Dclojure.spec.skip-macros=true \
	    -J-Dclojure.compiler.direct-linking=true \
	    -H:IncludeResources=SCI_VERSION \
	    -H:ReflectionConfigurationFiles=reflection.json \
	    -H:Log=registerResource: \
	    -J-Xmx3g \
	    -H:Name=$(@:%.so=%)

$(LIBSCI_CLASS): $(LIBSCI_JAVA) $(SCI_JAR)
	javac -cp $(SCI_JAR):$(SVM_JAR) $<

$(SCI_JAR):
	lein \
	    with-profiles +libsci,+native-image \
	    do clean, uberjar
