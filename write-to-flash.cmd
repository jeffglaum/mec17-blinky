@echo off
REM
REM Convert the ELF binary to a raw binary (without header), then use the Microchip
REM SPI image generator tool to format the binary for the boot ROM to use.  Finally
REM use probe-rs to write the final image to the external QSPI-connected NOR flash.
REM

set CURRENT_DIR=%CD%
set RELEASE_DIR=.\target\thumbv7em-none-eabihf\release
set FLASH_BASE_ADDRESS=0x50000000

REM Convert the ELF binary into a raw binary.
pushd %RELEASE_DIR%
arm-none-eabi-objcopy.exe -O binary mec17-blinky mec17-blinky.bin

REM Use the SPI image generator tool to format the binary for flash.
%CURRENT_DIR%\mec172x_spi_gen_win.exe -i %CURRENT_DIR%\spi_cfg.txt -o spi_image.bin
dir spi_image.bin 
popd

REM Write the final image to SPI NOR.
probe-rs download --binary-format bin --base-address %FLASH_BASE_ADDRESS% --chip MEC1723N_B0_SZ %RELEASE_DIR%\spi_image.bin
