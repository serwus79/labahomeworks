import { app, InvocationContext } from "@azure/functions";
import { BlobServiceClient } from "@azure/storage-blob";

export async function saveMessageToBlob(
  queueItem: unknown,
  context: InvocationContext
): Promise<void> {
  context.log("Storage queue function processed work item:", queueItem);

  const blobConnectionString = process.env.AzureWebJobsStorage;
  const containerName = process.env.BLOB_CONTAINER_NAME; // Nazwa kontenera
  const blobFileName = process.env.BLOB_FILE_NAME; // Nazwa pliku

  const blobServiceClient =
    BlobServiceClient.fromConnectionString(blobConnectionString);
  const containerClient = blobServiceClient.getContainerClient(containerName);
  const blobClient = containerClient.getBlockBlobClient(blobFileName);

  const jsonMessage = JSON.stringify(queueItem);

  try {
    await blobClient.upload(jsonMessage, jsonMessage.length);
    context.log(`Message saved to Blob Storage: ${jsonMessage}`);
  } catch (error) {
    context.error("Error uploading blob:", error);
  }
}

app.storageQueue("saveMessageToBlob", {
  queueName: "js-queue-items",
  connection: "AzureWebJobsStorage",
  handler: saveMessageToBlob,
});
