echo -e "\n${CYAN}====================================================${NC}"
echo -e "${CYAN}          AUTOMATED POST-INSTALL VERIFICATION       ${NC}"
echo -e "${CYAN}====================================================${NC}"

# 1. Verify THP Status (Both enabled & defrag)
echo -e "\n${YELLOW}[1/4] Verifying THP (Transparent Huge Pages) Settings:${NC}"
echo -n "  -> THP Enabled State: "
cat /sys/kernel/mm/transparent_hugepage/enabled
echo -n "  -> THP Defrag State:  "
cat /sys/kernel/mm/transparent_hugepage/defrag

# 2. Verify Service Status
echo -e "\n${YELLOW}[2/4] Verifying Splunkd Service Status:${NC}"
systemctl is-active --quiet Splunkd.service && echo -e "  -> Splunkd Service: ${GREEN}ACTIVE (Running)${NC}" || echo -e "  -> Splunkd Service: ${RED}INACTIVE${NC}"

# 3. Verify Systemd Limits Overrides
echo -e "\n${YELLOW}[3/4] Verifying Applied Resource Limits (override.conf):${NC}"
systemctl show Splunkd.service | grep -E "^(LimitNOFILE|LimitNPROC|LimitDATA|LimitCORE|LimitMEMLOCK)=" | sed 's/^/  -> /'

# 4. Verify Firewall Ports (if configured)
if [[ "$CONF_FIREWALL" =~ ^[Yy]$ ]] && systemctl is-active --quiet firewalld; then
    echo -e "\n${YELLOW}[4/4] Verifying Active Firewall Open Ports:${NC}"
    echo -n "  -> Open Ports: "
    firewall-cmd --list-ports
fi

echo -e "\n${GREEN}====================================================${NC}"
echo -e "${GREEN}      Splunk Setup Completed Successfully!          ${NC}"
echo -e "${GREEN}====================================================${NC}"

