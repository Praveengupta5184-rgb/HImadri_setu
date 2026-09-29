package in.gov.moes.ncpor.polarops.service;
import in.gov.moes.ncpor.polarops.model.*; import in.gov.moes.ncpor.polarops.repository.*; import lombok.*; import org.springframework.security.core.Authentication; import org.springframework.stereotype.Service;
@Service @RequiredArgsConstructor public class MissionAccessService {
 private final UserRepository users; private final MissionMemberRepository members;
 public boolean isOfficer(Authentication a){ return a.getAuthorities().stream().anyMatch(x -> x.getAuthority().matches("ROLE_(ADMIN|MISSION_OFFICER|STATION_OFFICER|LOGISTICS_OFFICER)")); }
 public boolean canAccess(Mission m, Authentication a){ if(isOfficer(a)) return true; return users.findByEmail(a.getName()).map(u -> u.getPersonnel()!=null && members.existsByMissionIdAndPersonnelIdAndMembershipStatus(m.getId(),u.getPersonnel().getId(),"ACTIVE")).orElse(false); }
 public boolean canSendLocation(Long personnelId, Mission m, Authentication a){ if(isOfficer(a)) return true; return users.findByEmail(a.getName()).map(u -> u.getPersonnel()!=null && u.getPersonnel().getId().equals(personnelId) && canAccess(m,a)).orElse(false); }
}
