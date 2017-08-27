FROM debian:stretch

MAINTAINER Harald Welte <laforge@gnumonks.org>

RUN	apt-get update && apt-get install -y \
	eclipse-titan

RUN	apt-get update && \
	apt-get upgrade -y && \
	apt-get -y install \
		build-essential \
		git && \
	apt-get clean

ARG	eclipsegit=https://github.com/eclipse
ARG	eclipsegit2=git://git.eclipse.org/gitroot/titan

RUN	git clone ${eclipsegit}/titan.Libraries.TCCUsefulFunctions && \
	git clone ${eclipsegit2}/titan.ProtocolModules.GRE && \
	git clone ${eclipsegit}/titan.ProtocolModules.ICMP && \
	git clone ${eclipsegit}/titan.ProtocolModules.ICMPv6 && \
	git clone ${eclipsegit}/titan.ProtocolModules.IP && \
	git clone ${eclipsegit}/titan.ProtocolModules.L2TP && \
	git clone ${eclipsegit2}/titan.ProtocolModules.M2PA && \
	git clone ${eclipsegit}/titan.ProtocolModules.M3UA && \
	git clone ${eclipsegit2}/titan.ProtocolModules.SCTP && \
	git clone ${eclipsegit}/titan.ProtocolModules.SMPP && \
	git clone ${eclipsegit2}/titan.ProtocolModules.SUA && \
	git clone ${eclipsegit}/titan.ProtocolModules.TCP && \
	git clone ${eclipsegit}/titan.ProtocolModules.UDP && \
	git clone ${eclipsegit}/titan.TestPorts.Common_Components.Socket-API && \
	git clone ${eclipsegit2}/titan.TestPorts.GPIO && \
	git clone ${eclipsegit}/titan.TestPorts.IPL4asp && \
	git clone ${eclipsegit}/titan.TestPorts.LANL2asp && \
	git clone ${eclipsegit}/titan.TestPorts.PCAPasp && \
	git clone ${eclipsegit}/titan.TestPorts.SCTPasp && \
	git clone ${eclipsegit}/titan.TestPorts.SIPmsg && \
	git clone ${eclipsegit}/titan.TestPorts.TCPasp && \
	git clone ${eclipsegit}/titan.TestPorts.TELNETasp && \
	git clone ${eclipsegit}/titan.TestPorts.UDPasp && \
	git clone ${eclipsegit}/titan.TestPorts.UNIX_DOMAIN_SOCKETasp

# somehow Debian folks updated the gcc version but not titan :/
RUN	sed -i 's/^#error/\/\/#error/' /usr/include/titan/cversion.h
