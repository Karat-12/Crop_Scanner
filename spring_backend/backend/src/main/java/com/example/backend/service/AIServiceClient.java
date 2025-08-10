package com.example.backend.service;

import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.http.MediaType;
import org.springframework.core.io.FileSystemResource;
import reactor.core.publisher.Mono;

import java.io.File;

@SuppressWarnings("unused")
@Service
public class AIServiceClient {

    private final WebClient webClient;

    public AIServiceClient() {
        this.webClient = WebClient.builder()
                .baseUrl("http://127.0.0.1:8000")
                .build();
    }

    public String analyzeImage(File imageFile) {
        try {
            return webClient.post()
                    .uri("/analyze")
                    .contentType(MediaType.MULTIPART_FORM_DATA)
                    .bodyValue(new org.springframework.util.LinkedMultiValueMap<String, Object>() {{
                        add("file", new FileSystemResource(imageFile));
                    }})
                    .retrieve()
                    .bodyToMono(String.class)
                    .block();
        } catch (Exception e) {
            return "{\"error\": \"" + e.getMessage() + "\"}";
        }
    }
}
