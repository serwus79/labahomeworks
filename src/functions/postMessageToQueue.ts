import { app, HttpRequest, HttpResponseInit, InvocationContext } from "@azure/functions";
import { QueueServiceClient } from "@azure/storage-queue";

export async function postMessageToQueue(request: HttpRequest, context: InvocationContext): Promise<HttpResponseInit> {
    context.log(`HTTP POST function processed request for url "${request.url}"`);

    const queueConnectionString = process.env.AzureWebJobsStorage;
    const queueName = process.env.QUEUE_NAME; // Nazwa kolejki

    const queueServiceClient = QueueServiceClient.fromConnectionString(queueConnectionString);
    const queueClient = queueServiceClient.getQueueClient(queueName);

    const message = (request.query.get("message") || await request.text())?.trim();

    if (!message) {
        return {
            status: 400,
            body: "Please provide a message in the request body or query string."
        };
    }

    try {
        await queueClient.sendMessage(Buffer.from(message).toString('base64')); // Zakodowanie wiadomości jako Base64
        context.log(`Message added to queue: ${message}`);

        return {
            status: 200,
            body: "Message added to the queue."
        };
    } catch (error) {
        context.error("Error adding message to queue:", error);
        return {
            status: 500,
            body: "Failed to add message to the queue."
        };
    }
}

app.http('postMessageToQueue', {
    methods: ['POST'],
    authLevel: 'anonymous',
    handler: postMessageToQueue
});
