function giefpasspls
    set -g EASY_PW_MAX 16
    set -g MEDIUM_PW_MAX 32
    set -g HARDCORE_PW_MAX 64
    set -g PWFILE .pwngen

    function quit_insecure
        echo ''
        echo 'Cannot continue, the application has been deemed unsafe to generate passwords, due to failed checks'
        exit 1
    end


    function dep_check
        if [ (dpkg-query -W -f='${Status}' $argv | grep -c "ok installed") -eq 0 ]
            echo "Missing dependency $argv"
            sudo apt install $argv -y
            return 1
        else
            return 0
        end
    end

    function integrity_check
        echo ' - Integrity check'
        if ! fish compare.fish
            echo 'Signature match failed, either one of the two following happened:'
            echo ' - The developer forgot to update the .signature.sig file after a new commit' 
            echo ' - Your files have been tampered with and do not compare from the latest commit'
            quit_insecure
        else
            echo 'Integrity check PASSED'
        end
        echo ""
    end

    function fips_140_2_test
        echo " - FIPS 140-2 check"
        set FIPSTEST (rngtest -c 10000 </dev/urandom)
        if test [ $FIPSTEST | sed -n '8p' | cut -d ':' -f 3 | xargs -gt 2 ]
            echo "FIPS 140-2 check PASSED"
            return 0
        else
            echo "FIPS 140-2 check FAILED"
            return 1
        end
        echo ""
        echo ""
    end

    function dieharder_test
        echo " - Dieharder RNG check"
        set DIEHARDER_WEAK_OR_FAILED_NUMBER_OF_TESTS (cat /dev/urandom | dieharder -g 200 -a -P 10 -Y 1 | grep -e "WEAK" -e "FAILED" | wc -l)
        if [ $DIEHARDER_WEAK_OR_FAILED_NUMBER_OF_TESTS -eq 0 ]
            echo "Dieharder RNG test PASSED"
        else
            echo "Dieharder RNG test FAILED ($DIEHARDER_WEAK_OR_FAILED_NUMBER_OF_TESTS tests have failed)"
            quit_insecure
        end
        echo ""
    end

    function check_kernel_entropy
        echo ' - Kernel entropy check'
        set ENTROPY_AVAIL (cat /proc/sys/kernel/random/entropy_avail)
        set ENTROPY_POOL (cat /proc/sys/kernel/random/poolsize)

        set ENTROPY_OK false
        if [ $ENTROPY_POOL -gt 4000 ]
            echo "/proc/sys/kernel/random/poolsize > $ENTROPY_POOL = OK"
            set ENTROPY_OK true
        end

        if [ $ENTROPY_AVAIL -gt 4000 ]
            echo "/proc/sys/kernel/random/entropy_avail > $ENTROPY_AVAIL = OK"
            set ENTROPY_OK true
        end

        if ! $ENTROPY_OK
            echo "Your available entropy bits is lower then 4000, installing haveged.."
            if dep_check "haveged"
                echo "Your system still has low entropy bits even after installing and starting haveged, please inspect haveged's status"
                sudo service haveged status
                quit_insecure
            else 
                sudo service haveged start
                check_kernel_entropy
            end
        else
            echo "Kernel entropy check PASSED"
        end
        echo ""
    end

    function check_tpm
        echo " - TPM module check"
        set TPM false
        [ -c /dev/tpmrm0 ] && set TPM tpmrm0
        [ -c /dev/tpm0 ] && set TPM tpm0
        if $TPM
            echo 'TPM module detected, using rng-tools to make use of TPM for RNG'
            sudo apt-get install rng-tools
            [ -c /dev/tpm0 ] && sed -i "s/\(^RNGD_OPTS=\).*/\1-r \/dev\/$TPM --fill-watermark=4096/" /etc/conf.d/rngd
            [ -c /dev/tpmrm0 ] && sed -i "s/\(^RNGD_OPTS=\).*/\1-r \/dev\/$TPM --fill-watermark=4096/" /etc/conf.d/rngd
            echo 'Edited /etc/conf.d/rngd to reflect using your TPM module, please double check to be sure:'
            cat /etc/conf.d/rngd
            echo 'Starting rngd service'
            sudo service rngd start
        else
            echo 'TPM module check FAILED (not found)'
        end
        echo ""
    end

    function ensure_deps
        echo " - Dependency check"
        set HAS_DEPS false
        if dep_check "xkcdpass"
            set HAS_DEPS true
        end
        if dep_check "pwgen"
            set HAS_DEPS true
        end
        if dep_check "dieharder"
            set HAS_DEPS true
        end
        if dep_check "ent"
            set HAS_DEPS true
        end

        if ! $HAS_DEPS
            quit_insecure
        end
        echo "Dependency check PASSED"
        echo ""
    end

    function print_logo
        echo ""
        printf "\

 ██████╗ ██╗███████╗███████╗██████╗  █████╗ ███████╗███████╗██████╗ ██╗     ███████╗
██╔════╝ ██║██╔════╝██╔════╝██╔══██╗██╔══██╗██╔════╝██╔════╝██╔══██╗██║     ██╔════╝
██║  ███╗██║█████╗  █████╗  ██████╔╝███████║███████╗███████╗██████╔╝██║     ███████╗
██║   ██║██║██╔══╝  ██╔══╝  ██╔═══╝ ██╔══██║╚════██║╚════██║██╔═══╝ ██║     ╚════██║
╚██████╔╝██║███████╗██║     ██║     ██║  ██║███████║███████║██║     ███████╗███████║
 ╚═════╝ ╚═╝╚══════╝╚═╝     ╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝     ╚══════╝╚══════╝
        " | cat
        echo ""
        echo "                          Made with ❤️️  for FOSS and privacy"
        echo ""
    end

    function gen_passwords
        function pwg 
            echo ""
            echo " ------------- pwgen: easy ------------- "
            pwgen -1 $EASY_PW_MAX -A -c 24 -C
            echo ""
            echo " ------------- pwgen: medium ------------- "
            pwgen -1 -y -n -c $MEDIUM_PW_MAX -c 16 -C
            echo ""
            echo " ------------- pwgen: hardcore ------------- "
            pwgen -1 -s -B -y -n -c -v -C $HARDCORE_PW_MAX -c 8
        end

        function xkdc
            echo ""
            echo " ------------- xkcdpass: easy ------------- "
            xkcdpass -C "upper" -d " " -n ( shuf -i3-6 -n1 ) --min ( shuf -i2-4 -n1 ) --max ( shuf -i4-6 -n1 )
            xkcdpass -C "upper" -d " " -n ( shuf -i3-6 -n1 ) --min ( shuf -i2-4 -n1 ) --max ( shuf -i4-6 -n1 )
            xkcdpass -C "lower" -d " " -n ( shuf -i2-6 -n1 ) --min ( shuf -i2-4 -n1 ) --max ( shuf -i4-6 -n1 )
            xkcdpass -C "lower" -d " " -n ( shuf -i3-6 -n1 ) --min ( shuf -i2-4 -n1 ) --max ( shuf -i4-6 -n1 )
            xkcdpass -C "first" -d " " -n ( shuf -i3-6 -n1 ) --min ( shuf -i2-4 -n1 ) --max ( shuf -i4-6 -n1 )
            xkcdpass -C "first" -d " " -n ( shuf -i2-6 -n1 ) --min ( shuf -i2-4 -n1 ) --max ( shuf -i4-6 -n1 )
            echo ""
            echo " ------------- xkcdpass: medium ------------- "
            xkcdpass -C "upper" -d (shuf -e '-' -e ' ' -e '_' -e '!' -n1) -n ( shuf -i3-6 -n1 ) --min ( shuf -i4-6 -n1 ) --max ( shuf -i6-9 -n1 )
            xkcdpass -C "upper" -d (shuf -e '-' -e ' ' -e '_' -e '!' -n1) -n ( shuf -i3-6 -n1 ) --min ( shuf -i4-6 -n1 ) --max ( shuf -i6-9 -n1 )
            xkcdpass -C "lower" -d (shuf -e '-' -e ' ' -e '_' -e '!' -n1) -n ( shuf -i2-6 -n1 ) --min ( shuf -i4-6 -n1 ) --max ( shuf -i6-9 -n1 )
            xkcdpass -C "lower" -d (shuf -e '-' -e ' ' -e '_' -e '!' -n1) -n ( shuf -i3-6 -n1 ) --min ( shuf -i4-6 -n1 ) --max ( shuf -i6-9 -n1 )
            xkcdpass -C "first" -d (shuf -e '-' -e ' ' -e '_' -e '!' -n1) -n ( shuf -i3-6 -n1 ) --min ( shuf -i4-6 -n1 ) --max ( shuf -i6-9 -n1 )
            xkcdpass -C "first" -d (shuf -e '-' -e ' ' -e '_' -e '!' -n1) -n ( shuf -i2-6 -n1 ) --min ( shuf -i4-6 -n1 ) --max ( shuf -i6-9 -n1 )
            echo ""
            echo " ------------- xkcdpass: hardcore ------------- "
            xkcdpass -C "upper" -d (shuf -e '-' -e ' ' -e '_' -e '!' -n1) -n ( shuf -i8-13 -n1 ) --min ( shuf -i6-8 -n1 ) --max ( shuf -i8-10 -n1 )
            xkcdpass -C "upper" -d (shuf -e '-' -e ' ' -e '_' -e '!' -n1) -n ( shuf -i8-13 -n1 ) --min ( shuf -i6-8 -n1 ) --max ( shuf -i8-10 -n1 )
            xkcdpass -C "lower" -d (shuf -e '-' -e ' ' -e '_' -e '!' -n1) -n ( shuf -i8-13 -n1 ) --min ( shuf -i6-8 -n1 ) --max ( shuf -i8-10 -n1 )
            xkcdpass -C "lower" -d (shuf -e '-' -e ' ' -e '_' -e '!' -n1) -n ( shuf -i8-13 -n1 ) --min ( shuf -i6-8 -n1 ) --max ( shuf -i8-10 -n1 )
            xkcdpass -C "first" -d (shuf -e '-' -e ' ' -e '_' -e '!' -n1) -n ( shuf -i8-13 -n1 ) --min ( shuf -i6-8 -n1 ) --max ( shuf -i8-10 -n1 )
            xkcdpass -C "first" -d (shuf -e '-' -e ' ' -e '_' -e '!' -n1) -n ( shuf -i8-13 -n1 ) --min ( shuf -i6-8 -n1 ) --max ( shuf -i8-10 -n1 )
        end

        pwg
        xkdc
    end

    function ready
        printf "\n\nTests are done, generating passwords:\n"
    end

    print_logo
    integrity_check
    ensure_deps
    check_tpm
    check_kernel_entropy
    # fips_140_2_test  # TODO: still testing 
    # dieharder_test   # TODO: still testing
    ready
    gen_passwords
end
