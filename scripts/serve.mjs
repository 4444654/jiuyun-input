import http from 'node:http';
import {readFile} from 'node:fs/promises';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'..');
const port=Number(process.env.PORT||4317);
const types={'.html':'text/html; charset=utf-8','.mjs':'text/javascript; charset=utf-8','.js':'text/javascript; charset=utf-8','.css':'text/css; charset=utf-8','.json':'application/json; charset=utf-8','.webmanifest':'application/manifest+json','.svg':'image/svg+xml','.md':'text/plain; charset=utf-8','.zip':'application/zip'};
const server=http.createServer(async(req,res)=>{try{let url=decodeURIComponent(new URL(req.url,'http://localhost').pathname);let base=url.startsWith('/packages/')?root:path.join(root,'apps/web');let file=path.resolve(base,'.'+(url==='/'?'/index.html':url));if(!file.startsWith(base+path.sep)){res.writeHead(403);return res.end('Forbidden');}let data=await readFile(file);res.writeHead(200,{'Content-Type':types[path.extname(file)]||'application/octet-stream','X-Content-Type-Options':'nosniff','Cache-Control':'no-cache'});res.end(data);}catch{res.writeHead(404);res.end('Not found');}});
server.listen(port,'127.0.0.1',()=>console.log('玖云输入法: http://127.0.0.1:'+server.address().port));
