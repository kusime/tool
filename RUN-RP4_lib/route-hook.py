#!/usr/bin/python

import os

gateway=open( '/home/kusime/Desktop/small-tool/RUN-RP4_lib/dest.gateway', mode="r")
gatewaylist=gateway.readlines()
gatewayindexlist=[]


for net in gatewaylist:
  cooked=net.strip('\n')
  if cooked != '0.0.0.0':
    gatewayindexlist.append(gatewaylist.index(net))

for index in gatewayindexlist:
  pattern=gatewaylist[index]
  os.system("sudo route del default gw %s"%(pattern))



net=open('/home/kusime/Desktop/small-tool/RUN-RP4_lib/route.net' , mode='r')
netlist=net.readlines()
netindexlist=[]



for netmask in netlist:
  cooked=netmask.strip('\n')
  if cooked != '0.0.0.0/0':
    netindexlist.append(netlist.index(netmask))

for index2 in netindexlist:
  pattern=netlist[index2]
  os.system("sudo route del -net  %s"%(pattern))

