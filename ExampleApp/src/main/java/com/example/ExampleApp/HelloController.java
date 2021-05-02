package com.example.ExampleApp;

import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseBody;

@RestController
public class HelloController {
    @GetMapping("/")
    @ResponseBody
    public String hello() {
        return "Hello World!";
    }
}
