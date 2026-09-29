package in.gov.moes.ncpor.polarops.service;

import in.gov.moes.ncpor.polarops.model.Mission;
import in.gov.moes.ncpor.polarops.model.Personnel;
import in.gov.moes.ncpor.polarops.model.User;
import in.gov.moes.ncpor.polarops.repository.MissionMemberRepository;
import in.gov.moes.ncpor.polarops.repository.UserRepository;
import org.junit.jupiter.api.Test;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.*;

class MissionAccessServiceTest {
    @Test void officerCanAccessMissionWithoutMembership() {
        MissionAccessService service = new MissionAccessService(mock(UserRepository.class), mock(MissionMemberRepository.class));
        Mission mission = Mission.builder().id(1L).build();
        var officer = new UsernamePasswordAuthenticationToken("officer@ncpor.gov.in", "n/a",
                List.of(new SimpleGrantedAuthority("ROLE_MISSION_OFFICER")));

        assertThat(service.canAccess(mission, officer)).isTrue();
    }

    @Test void activeMemberCanAccessOnlyTheirMission() {
        UserRepository users = mock(UserRepository.class);
        MissionMemberRepository members = mock(MissionMemberRepository.class);
        MissionAccessService service = new MissionAccessService(users, members);
        Personnel personnel = Personnel.builder().id(24L).build();
        when(users.findByEmail("member@ncpor.gov.in")).thenReturn(Optional.of(User.builder().personnel(personnel).build()));
        when(members.existsByMissionIdAndPersonnelIdAndMembershipStatus(1L, 24L, "ACTIVE")).thenReturn(true);
        when(members.existsByMissionIdAndPersonnelIdAndMembershipStatus(2L, 24L, "ACTIVE")).thenReturn(false);
        var member = new UsernamePasswordAuthenticationToken("member@ncpor.gov.in", "n/a", List.of());

        assertThat(service.canAccess(Mission.builder().id(1L).build(), member)).isTrue();
        assertThat(service.canAccess(Mission.builder().id(2L).build(), member)).isFalse();
    }

    @Test void memberCannotSubmitLocationForAnotherPerson() {
        UserRepository users = mock(UserRepository.class);
        MissionMemberRepository members = mock(MissionMemberRepository.class);
        MissionAccessService service = new MissionAccessService(users, members);
        Personnel personnel = Personnel.builder().id(24L).build();
        when(users.findByEmail("member@ncpor.gov.in")).thenReturn(Optional.of(User.builder().personnel(personnel).build()));
        var member = new UsernamePasswordAuthenticationToken("member@ncpor.gov.in", "n/a", List.of());

        assertThat(service.canSendLocation(25L, Mission.builder().id(1L).build(), member)).isFalse();
        verifyNoInteractions(members);
    }
}
