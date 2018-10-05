#!/usr/bin/env python

import os, sys
import csv
import sys
import sqlite3
from optparse import OptionParser

def parse_options():
    parser = OptionParser()

    parser.add_option("-c", "--mcc", dest="mcc", help="Mobile Country Code")
    parser.add_option("-n", "--mnc", dest="mnc", help="Mobile Network Code")
    (options, args) = parser.parse_args()

    return options, args

def create_hlr_3g(db):
	conn = sqlite3.connect(db)
	c = conn.execute(
		"""CREATE TABLE IF NOT EXISTS subscriber (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		imsi		VARCHAR(15) UNIQUE NOT NULL,
		msisdn		VARCHAR(15) UNIQUE,
		imeisv		VARCHAR,
		vlr_number	VARCHAR(15),
		hlr_number	VARCHAR(15),
		sgsn_number	VARCHAR(15),
		sgsn_address	VARCHAR,
		ggsn_number	VARCHAR(15),
		gmlc_number	VARCHAR(15),
		smsc_number	VARCHAR(15),
		periodic_lu_tmr	INTEGER,
		periodic_rau_tau_tmr INTEGER,
		nam_cs		BOOLEAN NOT NULL DEFAULT 1,
		nam_ps		BOOLEAN NOT NULL DEFAULT 1,
		lmsi		INTEGER,
		ms_purged_cs	BOOLEAN NOT NULL DEFAULT 0,
		ms_purged_ps	BOOLEAN NOT NULL DEFAULT 0
		);"""
	)
	c.close()
	c = conn.execute(
		"""CREATE TABLE IF NOT EXISTS subscriber_apn (
		subscriber_id	INTEGER,
		apn		VARCHAR(256) NOT NULL
		);"""
	)
	c.close()
	c = conn.execute(
		"""CREATE TABLE IF NOT EXISTS subscriber_multi_msisdn (
		subscriber_id	INTEGER,
		msisdn		VARCHAR(15) NOT NULL
		);"""
	)
	c.close()
	c = conn.execute(
		"""CREATE TABLE IF NOT EXISTS auc_2g (
		subscriber_id	INTEGER PRIMARY KEY,
		algo_id_2g	INTEGER NOT NULL,
		ki		VARCHAR(32) NOT NULL
		);"""
	)
	c.close()
	c = conn.execute(
		"""CREATE TABLE IF NOT EXISTS auc_3g (
		subscriber_id	INTEGER PRIMARY KEY,
		algo_id_3g	INTEGER NOT NULL,
		k		VARCHAR(32) NOT NULL,
		op		VARCHAR(32),
		opc		VARCHAR(32),
		sqn		INTEGER NOT NULL DEFAULT 0,
		ind_bitlen	INTEGER NOT NULL DEFAULT 5
		);"""
	)
	c.close()
	c = conn.execute(
		"""CREATE UNIQUE INDEX idx_subscr_imsi ON subscriber (imsi);"""
	)
	conn.commit()
	conn.close()

def write_hlr_3g(db, data):
	conn = sqlite3.connect(db)
	c = conn.execute(
		'INSERT INTO subscriber ' +
		'(imsi, msisdn) ' +
		'VALUES ' +
		'(?,?);',
		[
			data['imsi'],
			data['extension']
		],
	)
	sub_id= c.lastrowid
	c.close()
	c = conn.execute(
		'INSERT INTO auc_2g ' +
		'(subscriber_id, algo_id_2g, ki)' +
		'VALUES ' +
		'(?,?,?);',
		[
			sub_id,
			1,
			data['ki']
		],
	)
	c.close()
	c = conn.execute(
		'INSERT INTO auc_3g ' +
		'(subscriber_id, algo_id_3g, k, opc, sqn)' +
		'VALUES ' +
		'(?, ?, ?, ?, ?);',
		[
			sub_id,
			5,
			data['ki'],
			data['opc'],
			0
		],
	)
	conn.commit()
	conn.close()

def main():
        options, args = parse_options()

        infilename = args[0]
	csvfields = ['name', 'iccid', 'mcc', 'mnc', 'imsi', 'extension', 'smsp', 'ki', 'opc', 'adm1']

        try:
            create_hlr_3g("hlr.db")
        except sqlite3.OperationalError:
            print("hlr.db already exists, please remove!\n");
            sys.exit(1)

        msc = open("osmo-msc.cfg.patch", "w")
        msc.write("network\n")
        msc.write(" network country code %s\n" %(options.mcc))
        msc.write(" mobile network code %s\n" %(options.mnc))
        msc.write(" short name OsmoMSC-%s-%s\n" %(options.mcc, options.mnc))
        msc.write(" long name OsmoMSC-%s-%s\n" %(options.mcc, options.mnc))
        msc.close()

        os.system("osmo-config-merge osmo-msc.cfg.base osmo-msc.cfg.patch > osmo-msc.cfg")

	inf = open(infilename, "r")
	outf = open("simcards.csv", "w")

	cr = csv.DictReader(inf)
	cw = csv.DictWriter(outf, csvfields)

	cw.writeheader()
	for row in cr:
		imsi = row['imsi']
                if options.mcc:
                    imsi = options.mcc + imsi[3:]
                if options.mnc:
                    imsi = imsi[0:3] + options.mnc + imsi[5:]
                    
		data = {}
		data['name'] = "Subscriber " + row['iccid'][-6:-1]
		data['iccid'] = row['iccid']
                data['imsi'] = imsi
		data['mcc'] = data['imsi'][0:3]
		data['mnc'] = data['imsi'][3:5]
		data['ki'] = row['ki']
		data['opc'] = row['opc']
		data['extension'] = row['iccid'][-6:-1]
		data['smsp'] = '00495555'
		if "adm1" in row:
			data['adm1'] = row['adm1']
		cw.writerow(data)
		write_hlr_3g("hlr.db", data)
	inf.close()
	outf.close()


if __name__ == '__main__':
    main()

