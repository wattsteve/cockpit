# http://fedoraproject.org/wiki/Changes/CockpitManagementConsole
# =======================
# Cockpit Environmental Setup as Root (or with SUDO Privileges) on Fedora 21
# =======================
yum -y install http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
yum -y install trickle nbd-server python-libguestfs git qemu rpm-build nodejs npm mock qemu-kvm python curl libvirt-client libvirtd qemu-nbd krb5-workstation krb5-server 
yum remove ntfs* -y
yum remove firebird* -y
yum update -y

cd /opt
git clone https://github.com/cockpit-project/cockpit.git
cd cockpit
srpm=$(tools/make-srpm)
yum-builddep $srpm
npm install phantomjs -g
npm install jshint -g

# =======================
# Cockpit Build Environment Setup and Build:
# =======================
cd /opt/cockpit/
mkdir -p build
cd build
../autogen.sh --prefix=/usr --enable-maintainer-mode --enable-debug
make
make install
make check && make check-memory
yes | cp -rf ../src/bridge/cockpit.pam.insecure /etc/pam.d/cockpit
sh -c "cat ../src/bridge/sshd-reauthorize.pam >> /etc/pam.d/sshd"
systemctl daemon-reload
systemctl restart cockpit
mkdir -p ~/.local/share/cockpit
cd ../pkg/kubernetes/
ln -snf $PWD ~/.local/share/cockpit/kubernetes
ll ~/.local/share/cockpit
cockpit-bridge --packages
yum clean all
yum install --enablerepo=updates-testing cockpit
systemctl enable cockpit.socket
systemctl restart cockpit

