#!/usr/bin/env python3
"""Three independent Godot processes on localhost, not an Internet validation."""
import os, pathlib, socket, subprocess, tempfile, time, sys
root=pathlib.Path(__file__).resolve().parents[1]
env=os.environ.copy()
runtime=pathlib.Path(env.get('ARCHELYS_RUNTIME_ROOT','/tmp/archelys-network-test'))
for label,var in [('data','XDG_DATA_HOME'),('config','XDG_CONFIG_HOME'),('cache','XDG_CACHE_HOME')]:
    path=runtime/label;path.mkdir(parents=True,exist_ok=True);env[var]=str(path)
with socket.socket(socket.AF_INET,socket.SOCK_DGRAM) as reservation:
    reservation.bind(('127.0.0.1',0));port=reservation.getsockname()[1]
processes=[]
try:
    for role in ['host','client-a','client-b']:
        cmd=['godot','--headless','--path',str(root/'game'),'--script','res://tests/network_peer.gd','--',f'--role={role}',f'--port={port}']
        processes.append((role,subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,env=env)))
        time.sleep(0.5)
    failures=0
    for role,process in processes:
        output,_=process.communicate(timeout=20)
        print(output.strip())
        if process.returncode or 'ERROR:' in output:
            failures+=1
    sys.exit(1 if failures else 0)
finally:
    for _,process in processes:
        if process.poll() is None:
            process.terminate()
            try:process.wait(timeout=3)
            except subprocess.TimeoutExpired:process.kill()
