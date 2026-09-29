package in.gov.moes.ncpor.polarops.security;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.http.HttpMethod;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class SecurityConfig {

    @Autowired
    private JwtAuthenticationFilter jwtAuthFilter;
    @Autowired
    private MissionClosureFilter missionClosureFilter;
    
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
    
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .csrf(AbstractHttpConfigurer::disable)
            .cors(Customizer.withDefaults())
            .authorizeHttpRequests(auth -> auth
                .requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()
                .requestMatchers("/api/v1/auth/**", "/swagger-ui/**", "/v3/api-docs/**", "/api/health", "/").permitAll()
                .requestMatchers(HttpMethod.GET, "/api/v1/auth/users/**").hasRole("ADMIN")
                .requestMatchers(HttpMethod.PUT, "/api/v1/auth/users/**").hasRole("ADMIN")
                .requestMatchers(HttpMethod.POST, "/api/v1/expeditions/**").hasAnyRole("ADMIN", "MISSION_OFFICER")
                .requestMatchers(HttpMethod.PUT, "/api/v1/expeditions/**").hasAnyRole("ADMIN", "MISSION_OFFICER")
                .requestMatchers(HttpMethod.GET, "/api/v1/expeditions/**").hasAnyRole("ADMIN", "MISSION_OFFICER", "LOGISTICS_OFFICER", "STATION_OFFICER", "FIELD_OPERATOR")
                .requestMatchers(HttpMethod.POST, "/api/v1/missions/**").hasAnyRole("ADMIN", "MISSION_OFFICER")
                .requestMatchers(HttpMethod.PUT, "/api/v1/missions/**").hasAnyRole("ADMIN", "MISSION_OFFICER")
                .requestMatchers(HttpMethod.GET, "/api/v1/missions/**").hasAnyRole("ADMIN", "MISSION_OFFICER", "LOGISTICS_OFFICER", "STATION_OFFICER", "FIELD_OPERATOR")
                .requestMatchers(HttpMethod.POST, "/api/v1/personnel/*/kit").hasAnyRole("ADMIN", "LOGISTICS_OFFICER")
                .requestMatchers(HttpMethod.POST, "/api/v1/personnel/**").hasAnyRole("ADMIN", "MISSION_OFFICER", "STATION_OFFICER")
                .requestMatchers(HttpMethod.PUT, "/api/v1/personnel/**").hasAnyRole("ADMIN", "MISSION_OFFICER", "STATION_OFFICER")
                .requestMatchers(HttpMethod.DELETE, "/api/v1/personnel/**").hasRole("ADMIN")
                .requestMatchers("/api/v1/cargo/**").hasAnyRole("ADMIN", "MISSION_OFFICER", "LOGISTICS_OFFICER", "STATION_OFFICER", "FIELD_OPERATOR")
                .requestMatchers(HttpMethod.POST, "/api/v1/inventory/**").hasAnyRole("ADMIN", "LOGISTICS_OFFICER", "STATION_OFFICER")
                .requestMatchers(HttpMethod.PUT, "/api/v1/inventory/**").hasAnyRole("ADMIN", "LOGISTICS_OFFICER", "STATION_OFFICER")
                .requestMatchers(HttpMethod.DELETE, "/api/v1/inventory/**").hasRole("ADMIN")
                .requestMatchers("/api/v1/inventory/**").hasAnyRole("ADMIN", "MISSION_OFFICER", "LOGISTICS_OFFICER", "STATION_OFFICER")
                .requestMatchers("/api/v1/personnel/**").hasAnyRole("ADMIN", "MISSION_OFFICER", "STATION_OFFICER")
                .requestMatchers(HttpMethod.POST, "/api/v1/assets/**").hasAnyRole("ADMIN", "ASSET_OFFICER", "STATION_OFFICER")
                .requestMatchers(HttpMethod.PUT, "/api/v1/assets/**").hasAnyRole("ADMIN", "ASSET_OFFICER", "STATION_OFFICER")
                .requestMatchers(HttpMethod.PATCH, "/api/v1/assets/**").hasAnyRole("ADMIN", "ASSET_OFFICER", "STATION_OFFICER")
                .requestMatchers(HttpMethod.DELETE, "/api/v1/assets/**").hasRole("ADMIN")
                .requestMatchers("/api/v1/assets/**").hasAnyRole("ADMIN", "ASSET_OFFICER", "MISSION_OFFICER", "LOGISTICS_OFFICER", "STATION_OFFICER", "FIELD_OPERATOR")
                .requestMatchers("/api/v1/simulation/**").hasAnyRole("ADMIN", "MISSION_OFFICER")
                .requestMatchers("/api/v1/emergency/**").hasAnyRole("ADMIN", "MISSION_OFFICER", "STATION_OFFICER", "FIELD_OPERATOR")
                .anyRequest().authenticated()
            )
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class)
            .addFilterAfter(missionClosureFilter, JwtAuthenticationFilter.class);
        
        return http.build();
    }
}
