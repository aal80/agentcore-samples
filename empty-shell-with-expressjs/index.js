import express from 'express';
const app = express();

app.use(express.json());

app.get('/ping', (req, res) => {
	res.json({
		status: 'healthy'
	})
});

app.post('/invocations', (req, res) => {
	const body = req.body || {};

	res.json({
		"msg": "hello from AgentCore Empty Shell",
		"received_headers": req.headers,
		"received_payload": body
	});
});

const PORT = 8080;
const HOST = '0.0.0.0';
app.listen(PORT, HOST, () => {
	console.log(`Listening on http://localhost:${PORT}`);
});
