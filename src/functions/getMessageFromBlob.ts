import {
  app,
  HttpRequest,
  HttpResponseInit,
  InvocationContext,
} from "@azure/functions";
import { BlobServiceClient } from "@azure/storage-blob";

export async function getJsonFromBlob(
  request: HttpRequest,
  context: InvocationContext
): Promise<HttpResponseInit> {
  context.log(`HTTP GET function processed request for url "${request.url}"`);

  const blobConnectionString = process.env.AzureWebJobsStorage;
  const containerName = process.env.BLOB_CONTAINER_NAME; // Nazwa kontenera
  const blobFileName = process.env.BLOB_FILE_NAME; // Nazwa pliku

  const blobServiceClient =
    BlobServiceClient.fromConnectionString(blobConnectionString);
  const containerClient = blobServiceClient.getContainerClient(containerName);
  const blobClient = containerClient.getBlobClient(blobFileName);

  try {
    const downloadBlockBlobResponse = await blobClient.download();
    const downloadedContent = await streamToString(
      downloadBlockBlobResponse.readableStreamBody
    );

    return {
      status: 200,
      body: downloadedContent,
    };
  } catch (error) {
    context.error("Error downloading blob:", error);
    return {
      status: 404,
      body: "Blob not found.",
    };
  }
}

// Pomocnicza funkcja do przekształcenia strumienia na string
async function streamToString(readableStream: any): Promise<string> {
  return new Promise((resolve, reject) => {
    const chunks: string[] = [];
    readableStream.on("data", (data: any) => {
      chunks.push(data.toString());
    });
    readableStream.on("end", () => {
      resolve(chunks.join(""));
    });
    readableStream.on("error", reject);
  });
}

app.http("getJsonFromBlob", {
  methods: ["GET"],
  authLevel: "anonymous",
  handler: getJsonFromBlob,
});
