#!/bin/bash

#vagrant destroy --force
#set -x

vagrant up
#vagrant provision

vagrant ssh left -- sudo chmod a+rwx /mnt/first
vagrant ssh right -- sudo chmod a+rwx /mnt/first

for i in {0..12..2}; do
    filesize=$(( 2 ** $i ))k
    TEST_FILE=TEST_FILE.${filesize}
    GUEST_PATH=/mnt/first

    echo ====== Test pass - file $filesize ======
    dd if=/dev/urandom bs=${filesize} count=1 of=/tmp/${TEST_FILE}
    EXPECTED_SUM=$( md5sum < /tmp/${TEST_FILE} )

    echo ----------- Both nodes are online ---
    echo "Copy file to left node"
    ( cd /tmp; tar cf - ${TEST_FILE} ) | \
            vagrant ssh left -- "cd ${GUEST_PATH};  tar xfv -"

    GOT_SUM=$( vagrant ssh left -- "md5sum < ${GUEST_PATH}/${TEST_FILE}" )
    echo Left machine: Got sum ${GOT_SUM} , expected ${EXPECTED_SUM}
    [ "${GOT_SUM}" = "${EXPECTED_SUM}" ] || exit 1

    GOT_SUM=$( vagrant ssh right -- "md5sum < ${GUEST_PATH}/${TEST_FILE}" )
    echo Right node: Got sum ${GOT_SUM} , expected ${EXPECTED_SUM}
    [ "${GOT_SUM}" = "${EXPECTED_SUM}" ] || exit 1

    echo ----------- Stopped right node ---
    vagrant halt right

    dd if=/dev/urandom bs=${filesize} count=1 of=/tmp/${TEST_FILE}
    EXPECTED_SUM=$( md5sum < /tmp/${TEST_FILE} )

    echo "Copy file to left node"
    ( cd /tmp; tar cf - ${TEST_FILE} ) | \
            vagrant ssh left -- "cd ${GUEST_PATH};  tar xfv -"

    GOT_SUM=$( vagrant ssh left -- "md5sum < ${GUEST_PATH}/${TEST_FILE}" )
    echo Left machine: Got sum ${GOT_SUM} , expected ${EXPECTED_SUM}
    [ "${GOT_SUM}" = "${EXPECTED_SUM}" ] || exit 1

    vagrant up right
    sleep 5

    GOT_SUM=$( vagrant ssh right -- "md5sum < ${GUEST_PATH}/${TEST_FILE}" )
    echo Right node: Got sum ${GOT_SUM} , expected ${EXPECTED_SUM}
    [ "${GOT_SUM}" = "${EXPECTED_SUM}" ] || exit 1

    echo ----------- Stopped left node ---
    vagrant halt left

    dd if=/dev/urandom bs=${filesize} count=1 of=/tmp/${TEST_FILE}
    EXPECTED_SUM=$( md5sum < /tmp/${TEST_FILE} )

    echo "Copy file to right node"
    ( cd /tmp; tar cf - ${TEST_FILE} ) | \
            vagrant ssh right -- "cd ${GUEST_PATH};  tar xfv -"

    echo "Start left node"
    vagrant up left
    sleep 5

    GOT_SUM=$( vagrant ssh left -- "md5sum < ${GUEST_PATH}/${TEST_FILE}" )
    echo Left machine: Got sum ${GOT_SUM} , expected ${EXPECTED_SUM}
    [ "${GOT_SUM}" = "${EXPECTED_SUM}" ] || exit 1

    GOT_SUM=$( vagrant ssh right -- "md5sum < ${GUEST_PATH}/${TEST_FILE}" )
    echo Right node: Got sum ${GOT_SUM} , expected ${EXPECTED_SUM}
    [ "${GOT_SUM}" = "${EXPECTED_SUM}" ] || exit 1

done

#vagrant destroy --force
