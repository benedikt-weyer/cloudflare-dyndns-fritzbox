from cloudflare import Cloudflare
import flask

app = flask.Flask(__name__)


@app.route('/', methods=['GET'])
def main():
    token = flask.request.args.get('token')
    zone_name = flask.request.args.get('zone')
    ipv4 = flask.request.args.get('ipv4')

    if not token or not zone_name or not ipv4:
        return flask.jsonify({'status': 'error', 'message': 'Missing required parameters. token, zone and ipv4 are required.'}), 400

    cf = Cloudflare(api_token=token)
    
    zones = cf.zones.list(name=zone_name)
    found_zone = None
    for zone in zones:
        if zone.name == zone_name:
            found_zone = zone
            break

    if not found_zone:
        return flask.jsonify({'status': 'error', 'message': 'Zone not found.'}), 404


    a_records = cf.dns.records.list(zone_id=found_zone.id, match='all', type='A')
    
    found_a_record = None
    for a_record in a_records:
        if a_record.name == zone_name:
            found_a_record = a_record
            break

    if not found_a_record:
        return flask.jsonify({'status': 'error', 'message': 'A record not found.'}), 404
    
    
    cf.dns.records.update(
        dns_record_id=found_a_record.id, 
        zone_id=found_zone.id,
        name=found_a_record.name, 
        type='A', 
        content=ipv4
    )
    
    return flask.jsonify({'status': 'success', 'message': 'Update successful.'}), 200


import os
import waitress

app.secret_key = os.urandom(24)
waitress.serve(app, host='0.0.0.0', port=8080)