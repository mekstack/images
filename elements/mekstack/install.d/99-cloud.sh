useradd -m -d /var/cloud/ -u 69 cloud

cat > /etc/sudoers.d/cloud << EOF
cloud ALL=(ALL) NOPASSWD:ALL
EOF
chmod 0440 /etc/sudoers.d/cloud
visudo -c || rm /etc/sudoers.d/cloud

chown -R cloud:cloud /var/cloud
