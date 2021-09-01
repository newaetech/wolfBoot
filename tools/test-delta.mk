test-delta-update:SIGN_ARGS?=--ecc256
test-delta-update:SIGN_DELTA_ARGS?=--ecc256 --encrypt /tmp/enc_key.der
test-delta-update:USBTTY?=/dev/ttyACM0
test-delta-update:TIMEOUT?=60
test-delta-update:EXPVER=tools/test-expect-version/test-expect-version /dev/ttyACM0

test-delta-update: factory.bin test-app/image.bin tools/uart-flash-server/ufserver tools/delta/bmdiff tools/test-expect-version/test-expect-version
	@st-flash erase
	@st-flash reset
	@diff .config config/examples/stm32wb-delta.config || (echo "\n\n*** Error: please copy config/examples/stm32wb-delta.config to .config to run this test\n\n" && exit 1)
	$(SIGN_TOOL) $(SIGN_ARGS) --delta test-app/image_v1_signed.bin test-app/image.bin \
		$(PRIVATE_KEY) 7
	$(SIGN_TOOL) $(SIGN_ARGS) --delta test-app/image_v1_signed.bin test-app/image.bin \
		$(PRIVATE_KEY) 2
	@st-flash write factory.bin 0x08000000
	@echo Expecting version '1'
	@(test `$(EXPVER)` -eq 1)
	@echo
	@st-flash write test-app/image_v7_signed_diff.bin 0x0802C000
	@sleep 1
	@st-flash reset
	@echo Expecting version '1'
	@(test `$(EXPVER)` -eq 1)
	@sleep 2
	@st-flash reset
	@echo Expecting version '7'
	@(test `$(EXPVER)` -eq 7)
	@sleep 2
	@st-flash reset
	@echo Expecting version '7'
	@(test `$(EXPVER)` -eq 7)
	@sleep 2
	@st-flash reset
	@echo Expecting version '1'
	@(test `$(EXPVER)` -eq 1)
	@st-flash erase
	@st-flash reset
	@st-flash write factory.bin 0x08000000
	@echo Expecting version '1'
	@(test `$(EXPVER)` -eq 1)
	@sleep 1
	@st-flash write test-app/image_v2_signed_diff.bin 0x0802C000
	@st-flash reset
	@echo Expecting version '2'
	@(test `$(EXPVER)` -eq 2)
	@sleep 2
	@st-flash reset
	@echo Expecting version '2'
	@(test `$(EXPVER)` -eq 2)
	@sleep 2
	@st-flash reset
	@echo Expecting version '2'
	@(test `$(EXPVER)` -eq 2)
	@echo "TEST SUCCESSFUL"

